defmodule GarrulusWeb.SubscriptionsLive do
  use GarrulusWeb, :live_view
  alias Garrulus.Accounts
  alias Garrulus.Reader

  def mount(_params, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)

    {:ok,
     socket
     |> assign(:current_user, Accounts.get_user_by_session_token(user_token))
     |> assign(:subscriptions, Reader.list_user_subscriptions(user))}
  end
end
