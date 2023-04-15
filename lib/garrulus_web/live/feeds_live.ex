defmodule GarrulusWeb.FeedsLive do
  use GarrulusWeb, :live_view
  alias Garrulus.Accounts
  alias Garrulus.Reader

  def mount(_params, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)
    changeset = Reader.change_feed(%Reader.Feed{})

    socket =
      socket
      |> assign(:current_user, Accounts.get_user_by_session_token(user_token))
      |> assign(feeds: Reader.list_feeds(), trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("create", %{"feed" => feed_params}, socket) do
    # some defaults
    feed_params = Map.put(feed_params, "last_fetched", DateTime.utc_now())
    feed_params = Map.put(feed_params, "last_failed", DateTime.utc_now())
    feed_params = Map.put(feed_params, "backoff", 0)
    feed_params = Map.put(feed_params, "next_fetch", DateTime.utc_now())
    feed_params = Map.put(feed_params, "etag", "dummy")
    feed_params = Map.put(feed_params, "guid", feed_params["url"])

    case Reader.create_feed(feed_params) do
      {:ok, feed} ->
        {:noreply, assign(socket, :feeds, [feed | socket.assigns.feeds])}

      {:error, changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "feed")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
