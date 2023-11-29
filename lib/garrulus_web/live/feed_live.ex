defmodule GarrulusWeb.FeedLive do
  use GarrulusWeb, :live_view
  alias Garrulus.Accounts
  alias Garrulus.Reader

  def mount(params, %{"user_token" => user_token}, socket) do
    _user = Accounts.get_user_by_session_token(user_token)
    feed_id = Map.get(params, "feed_id")
    IO.puts("feed_id: #{feed_id}")
    feed = Reader.get_feed!(feed_id)
    entries = Reader.list_feed_entries(feed)

    socket =
      socket
      |> assign(:current_user, Accounts.get_user_by_session_token(user_token))
      |> assign(feed: feed)
      |> assign(entries: entries)

    {:ok, socket, temporary_assigns: []}
  end
end
