defmodule GarrulusWeb.EntriesLive do
  use GarrulusWeb, :live_view
  alias Garrulus.Accounts
  alias Garrulus.Reader

  def mount(_params, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)

    socket =
      socket
      |> assign(:current_user, Accounts.get_user_by_session_token(user_token))
      |> assign(
        entries: Reader.list_unread_user_uentries(user),
        trigger_submit: false,
        check_errors: false
      )

    {:ok, socket, temporary_assigns: []}
  end
end
