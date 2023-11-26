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
        upcoming_entries: Reader.list_unread_user_uentries(user, 2),
        current_entry: Reader.get_current_user_uentry(user),
        recent_read_entries: Reader.list_recent_read_user_uentries(user, 2),
        trigger_submit: false,
        check_errors: false
      )

    {:ok, socket, temporary_assigns: []}
  end
end
