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
    # sanity check: don't refetch if last fetched less than an hour ago
    hour_ago = DateTime.utc_now() |> DateTime.add(-3600, :second)

    # TODO: utc error
    if feed.last_fetched > hour_ago do
      {:error, feed}
    else
      {:ok, feed}
    end
  end

  defp jitter({:error, feed}), do: {:error, feed}

  defp jitter({:ok, feed}) do
    # jitter for up to a minute
    one_minute = 60 * 1000
    jitter = :rand.uniform(one_minute)
    :timer.sleep(jitter)
    # then just pass through
    {:ok, feed}
  end

  def fetch_url({:error, feed}), do: {:error, feed}

  def fetch_url({:ok, feed}) do
    url = feed.url
    etag = feed.etag
    IO.puts("fetching #{url}")
    modified = feed.last_fetched |> DateTime.from_naive!("Etc/UTC") |> DateTime.to_iso8601()
    headers = [] |> add_etag(etag) |> add_ims(modified)
    options = [recv_timeout: 10000]
    now = DateTime.utc_now()

    case HTTPoison.get(url, headers, options) do
      {:ok, r} ->
        IO.puts(r.status_code)

        {"ETag", etag} = List.keyfind(r.headers, "ETag", 0, {"ETag", feed.etag})

        Garrulus.Reader.update_feed(feed, %{
          last_fetched: now,
          etag: etag
        })

        {:ok, feed, r}

      _ ->
        IO.puts("error fetching #{url}")
        {:error, feed, nil}
    end
  end

  defp parse_feed_data({:error, feed, r}), do: {:error, feed, r}

  defp parse_feed_data({:ok, feed, r}) do
    case FastRSS.parse_rss(r.body) do
      {:ok, map_of_rss} ->
        handle_rss(feed, map_of_rss)

      {:error, _reason} ->
        case FastRSS.parse_atom(r.body) do
          {:ok, map_of_atom} ->
            handle_atom(feed, map_of_atom)

          {:error, reason} ->
            IO.puts("not Atom either")
            IO.puts(reason)
            {:error, feed}
        end
    end
  end

  defp handle_rss(feed, map_of_rss) do
    # TODO: update feed attributes if those have changed
    Enum.each(map_of_rss["items"], fn entry ->
      title = entry["title"] || "no title"
      link = entry["link"]
      guid = entry["guid"] || link
      author = entry["author"] || "no author"
      published = entry["pub_date"] || DateTime.utc_now()
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

      Reader.create_entry_if_not_exists(attrs)
    end)

    {:ok, feed}
  end

  defp handle_atom(feed, map_of_atom) do
    # TODO: update feed attributes if those have changed
    Enum.each(map_of_atom["entries"], fn entry ->
      title = entry["title"]["value"]
      guid = entry["id"]
      link = Enum.at(entry["links"], 0)["href"]
      author = Enum.at(entry["authors"], 0)["name"]
      published = entry["updated"]
      description = entry["content"]["value"]

      attrs = %{
        feed_id: feed.id,
        title: title,
        link: link,
        published: published,
        guid: guid,
        author: author,
        description: description
      }

      Reader.create_entry_if_not_exists(attrs)
    end)

    {:ok, feed}
  end

  defp schedule_next_fetch({:error, feed}) do
    backoff_schedule = [1, 2, 5, 10, 20, 50, 100]
    now = DateTime.utc_now()
    next_fetch = Timex.shift(now, hours: Enum.at(backoff_schedule, feed.backoff))

    new_backoff = min(feed.backoff + 1, length(backoff_schedule) - 1)

    Garrulus.Reader.update_feed(feed, %{
      last_fetched: now,
      next_fetch: next_fetch,
      last_failed: now,
      backoff: new_backoff
    })
  end

  defp schedule_next_fetch({:ok, feed}) do
    now = DateTime.utc_now()
    next_fetch = Timex.shift(now, hours: 1)
    Garrulus.Reader.update_feed(feed, %{last_fetched: now, next_fetch: next_fetch, backoff: 0})
  end
end
