defmodule GarrulusWeb.PageController do
  use GarrulusWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def fetch_form(conn, %{"url" => ""}) do
    render(conn, "fetch.html", layout: false, url: "")
  end

  def fetch_form(conn, %{"url" => url}) do
    # The form page is often custom made,
    # so skip the default app layout.
    headers = []
    options = [recv_timeout: 10000]
    {:ok, r} = HTTPoison.get(url, headers, options)
    IO.inspect(r)
    case FastRSS.parse_rss(r.body) do
      {:ok, map_of_rss} ->
        IO.inspect(map_of_rss)
      {:error, reason} ->
        IO.puts("not RSS")
        case FastRSS.parse_atom(r.body) do
          {:ok, map_of_atom} ->
            IO.inspect(map_of_atom)
          {:error, reason} ->
            IO.puts("not Atom")
            IO.puts(reason)
        end
    end
    
    render(conn, "fetch.html", layout: false, url: url, response: r)
  end
end
