defmodule Garrulus.Reader.Worker do
  def start_quote(s) do
    cond do
      String.starts_with?(s, "\"") ->
        s

      true ->
        "\"" <> s
    end
  end

  def end_quote(s) do
    cond do
      String.ends_with?(s, "\"") ->
        s

      true ->
        s <> "\""
    end
  end

  def ensure_quoted(s) do
    s |> String.trim() |> start_quote |> end_quote
  end

  def add_etag(headers, nil), do: headers
  def add_etag(headers, etag), do: [{"ETag", ensure_quoted(etag)} | headers]

  def add_ims(headers, nil), do: headers
  def add_ims(headers, modified), do: [{"If-Modified-Since", modified} | headers]

  def fetch_url(url, etag \\ nil, modified \\ nil) do
    IO.puts("fetching #{url}")
    headers = [] |> add_etag(etag) |> add_ims(modified)
    options = [recv_timeout: 10000]
    {:ok, r} = HTTPoison.get(url, headers, options)
    IO.inspect(r)
    r
  end

  def fetch_url_async(url) do
    Task.start(fn ->
      fetch_url(url)
    end)
  end

  def fetch_feed(feed) do
    Task.start(fn -> _fetch_feed(feed) end)
  end

  defp _fetch_feed(feed) do
    IO.puts("fetching feed #{feed.title}")

    feed
    |> sanity_check
    |> jitter
    |> fetch_feed_data

    # parse feed
    # process entries
    # update status: etag, last_fetched, failure, backoff, etc
    # schedule next fetch
  end

  defp sanity_check(feed) do
    # sanity check: don't refetch if last fetched less than an hour ago
    hour_ago = DateTime.utc_now() |> DateTime.add(-3600, :second)

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
    _jitter = :rand.uniform(one_minute)
    # sleep(jitter)
    # then just pass through
    {:ok, feed}
  end

  defp fetch_feed_data({:error, feed}), do: {:error, feed}

  defp fetch_feed_data({:ok, feed}) do
    fetch_url(feed.url)
  end
end
