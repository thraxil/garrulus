defmodule Garrulus.Reader.Worker do
  alias Garrulus.Reader

  def fetch_feed(feed) do
    Task.start(fn -> _fetch_feed(feed) end)
  end

  defp start_quote(s) do
    cond do
      String.starts_with?(s, "\"") ->
        s

      true ->
        "\"" <> s
    end
  end

  defp end_quote(s) do
    cond do
      String.ends_with?(s, "\"") ->
        s

      true ->
        s <> "\""
    end
  end

  defp ensure_quoted(s) do
    s |> String.trim() |> start_quote |> end_quote
  end

  defp add_etag(headers, nil), do: headers
  defp add_etag(headers, etag), do: [{"ETag", ensure_quoted(etag)} | headers]

  defp add_ims(headers, nil), do: headers
  defp add_ims(headers, modified), do: [{"If-Modified-Since", modified} | headers]

  defp _fetch_feed(feed) do
    IO.puts("fetching feed #{feed.title}")

    feed
    |> sanity_check
    |> jitter
    |> fetch_url
    |> parse_feed_data
    |> schedule_next_fetch
  end

  defp sanity_check(feed) do
    # sanity check: don't refetch if last fetched less than 30 min ago
    cutoff = DateTime.utc_now() |> DateTime.add(-1800, :second)

    if feed.last_fetched |> DateTime.from_naive!("Etc/UTC") > cutoff do
      {:error, feed, %{:status => :skipped}}
    else
      {:ok, feed, %{}}
    end
  end

  defp jitter({:error, feed, log}), do: {:error, feed, log}

  defp jitter({:ok, feed, log}) do
    # jitter for up to a minute
    one_minute = 60 * 1000
    jitter = :rand.uniform(one_minute)
    :timer.sleep(jitter)
    # then just pass through
    {:ok, feed, log}
  end

  def fetch_url({:error, feed, log}), do: {:error, feed, nil, log}

  def fetch_url({:ok, feed, log}) do
    url = feed.url
    etag = feed.etag
    IO.puts("fetching #{url}")
    modified = feed.last_fetched |> DateTime.from_naive!("Etc/UTC") |> DateTime.to_iso8601()
    headers = [] |> add_etag(etag) |> add_ims(modified)
    options = [recv_timeout: 10000]
    now = DateTime.utc_now()

    case HTTPoison.get(url, headers, options) do
      {:ok, r} ->
        {"ETag", etag} = List.keyfind(r.headers, "ETag", 0, {"ETag", feed.etag})

        Garrulus.Reader.update_feed(feed, %{
          last_fetched: now,
          etag: etag
        })

        {:ok, feed, r,
         Map.merge(log, %{
           :status => :ok,
           :response_status_code => r.status_code,
           :response_body => r.body
         })}

      _ ->
        IO.puts("error fetching #{url}")
        {:error, feed, nil, Map.merge(log, %{:status => :failed})}
    end
  end

  defp parse_feed_data({:error, feed, _r, log}), do: {:error, feed, log}

  defp parse_feed_data({:ok, feed, r, log}) do
    case FastRSS.parse_rss(r.body) do
      {:ok, map_of_rss} ->
        handle_rss(feed, map_of_rss, log)

      {:error, _reason} ->
        case FastRSS.parse_atom(r.body) do
          {:ok, map_of_atom} ->
            handle_atom(feed, map_of_atom, log)

          {:error, reason} ->
            IO.puts("not Atom either")
            IO.puts(reason)
            {:error, feed, Map.merge(log, %{:status => :failed})}
        end
    end
  end

  defp parse_pub_date(nil), do: DateTime.utc_now()

  defp parse_pub_date(pub_date) do
    case DateTime.from_iso8601(pub_date) do
      {:ok, dt} ->
        dt

      {:error, _reason} ->
        case Timex.parse(pub_date, "{RFC1123}") do
          {:ok, dt} ->
            dt

          {:error, _reason} ->
            DateTime.utc_now()
        end
    end
  end

  defp extract_guid(%{"permalink" => _permalink, "value" => guid}), do: guid

  defp extract_guid(guid), do: guid

  defp handle_rss(feed, map_of_rss, log) do
    # TODO: update feed attributes if those have changed
    created =
      Enum.sum(
        Enum.map(map_of_rss["items"], fn entry ->
          title = String.slice(entry["title"] || "no title", 0..254)
          link = String.slice(entry["link"], 0..254)
          guid = String.slice(extract_guid(entry["guid"]) || link, 0..254)
          author = String.slice(entry["author"] || "no author", 0..254)
          published = parse_pub_date(entry["pub_date"])
          description = entry["description"] || ""

          attrs = %{
            feed_id: feed.id,
            title: title,
            link: link,
            published: published,
            guid: guid,
            author: author,
            description: description
          }

          {:ok, _, cnt} = Reader.create_entry_if_not_exists(attrs)
          cnt
        end)
      )

    {:ok, feed, Map.merge(log, %{new_entries: created})}
  end

  defp handle_atom(feed, map_of_atom, log) do
    # TODO: update feed attributes if those have changed
    created =
      Enum.sum(
        Enum.map(map_of_atom["entries"], fn entry ->
          title = String.slice(entry["title"]["value"], 0..254) || "no title"
          guid = String.slice(entry["id"], 0..254)
          link = String.slice(Enum.at(entry["links"], 0)["href"], 0..254)
          author = String.slice(Enum.at(entry["authors"], 0)["name"] || "no author", 0..254)
          published = entry["updated"]
          description = entry["content"]["value"] || ""

          attrs = %{
            feed_id: feed.id,
            title: title,
            link: link,
            published: published,
            guid: guid,
            author: author,
            description: description
          }

          {:ok, _, cnt} = Reader.create_entry_if_not_exists(attrs)
          cnt
        end)
      )

    {:ok, feed, Map.merge(log, %{new_entries: created})}
  end

  defp schedule_next_fetch({:error, feed, log}) do
    IO.puts("scheduling next fetch on failed feed. #{feed.url}")
    IO.puts("backoff: #{feed.backoff}")
    # hours. max out at about two days.
    backoff_schedule = [1, 2, 5, 10, 20, 50]

    now = DateTime.utc_now()
    next_fetch = Timex.shift(now, hours: Enum.at(backoff_schedule, feed.backoff))
    jitter = :rand.uniform(60) - 30
    next_fetch = Timex.shift(next_fetch, minutes: jitter)

    new_backoff = min(feed.backoff + 1, length(backoff_schedule) - 1)

    IO.puts("next fetch: #{next_fetch}")

    Garrulus.Reader.update_feed(feed, %{
      last_fetched: now,
      next_fetch: next_fetch,
      last_failed: now,
      backoff: new_backoff
    })

    IO.puts("feed updated")

    Garrulus.Reader.log_fetch(
      feed,
      Map.get(log, :status, :error),
      Map.get(log, :response_status_code, 200),
      Map.get(log, :response_body, ""),
      Map.get(log, :new_entries, 0)
    )
  end

  defp schedule_next_fetch({:ok, feed, log}) do
    now = DateTime.utc_now()
    next_fetch = Timex.shift(now, hours: 1)
    jitter = :rand.uniform(60) - 30
    next_fetch = Timex.shift(next_fetch, minutes: jitter)

    Garrulus.Reader.update_feed(feed, %{last_fetched: now, next_fetch: next_fetch, backoff: 0})

    Garrulus.Reader.log_fetch(
      feed,
      Map.get(log, :status, :ok),
      Map.get(log, :response_status_code, 200),
      Map.get(log, :response_body, ""),
      Map.get(log, :new_entries, 0)
    )
  end
end
