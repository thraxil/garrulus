defmodule GarrulusWeb.SubscriptionsLive do
  use GarrulusWeb, :live_view
  alias Garrulus.Accounts
  alias Garrulus.Reader

  def mount(_params, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)

    feeds = Reader.list_user_non_subscriptions(user)
    subscriptions = Reader.list_user_subscriptions(user)

    {:ok,
     socket
     |> assign(:current_user, user)
     |> assign(:feeds, feeds)
     |> assign(:subscriptions, subscriptions)}
  end

  def handle_event("subscribe", %{"feed_id" => feed_id}, socket) do
    %{assigns: %{current_user: user}} = socket
    feed = Reader.get_feed!(feed_id)
    Reader.subscribe(user, feed)
    feeds = Reader.list_user_non_subscriptions(user)
    subscriptions = Reader.list_user_subscriptions(user)
    {:noreply, socket |> assign(:feeds, feeds) |> assign(:subscriptions, subscriptions)}
  end

  def handle_event("unsubscribe", %{"subscription-id" => subscription_id}, socket) do
    %{assigns: %{current_user: user}} = socket
    subscription = Reader.get_subscription!(subscription_id)
    Reader.delete_subscription(subscription)
    feeds = Reader.list_user_non_subscriptions(user)
    subscriptions = Reader.list_user_subscriptions(user)
    {:noreply, socket |> assign(:feeds, feeds) |> assign(:subscriptions, subscriptions)}
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
