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
        upcoming_entries: Reader.list_unread_user_uentries(user, 10),
        unread_entries_count: Reader.count_unread_user_uentries(user),
        current_entry: Reader.get_current_user_uentry(user),
        recent_read_entries: Enum.reverse(Reader.list_recent_read_user_uentries(user, 2)),
        trigger_submit: false,
        check_errors: false
      )

    {:ok, socket, temporary_assigns: []}
  end

  def handle_event("key_event", %{"key" => "j", "uentry_id" => id}, socket) do
    %{assigns: %{current_user: user}} = socket
    uentry = Reader.get_uentry!(id)
    Reader.update_uentry(uentry, %{read: true})

    socket =
      socket
      |> assign(
        upcoming_entries: Reader.list_unread_user_uentries(user, 10),
        unread_entries_count: Reader.count_unread_user_uentries(user),
        current_entry: Reader.get_current_user_uentry(user),
        recent_read_entries: Enum.reverse(Reader.list_recent_read_user_uentries(user, 2)),
        trigger_submit: false,
        check_errors: false
      )

    {:noreply, socket}
  end

  def handle_event("key_event", %{"key" => "k", "uentry_id" => _id}, socket) do
    IO.puts("k")
    %{assigns: %{current_user: user}} = socket

    socket =
      socket
      |> assign(
        upcoming_entries: Reader.list_unread_user_uentries(user, 10),
        unread_entries_count: Reader.count_unread_user_uentries(user),
        current_entry: Reader.get_current_user_uentry(user),
        recent_read_entries: Enum.reverse(Reader.list_recent_read_user_uentries(user, 2)),
        trigger_submit: false,
        check_errors: false
      )

    {:noreply, socket}
  end

  def handle_event("key_event", %{"key" => "r"}, socket) do
    # force reload
    IO.puts("handling r")
    %{assigns: %{current_user: user}} = socket

    socket =
      socket
      |> assign(
        upcoming_entries: Reader.list_unread_user_uentries(user, 10),
        unread_entries_count: Reader.count_unread_user_uentries(user),
        current_entry: Reader.get_current_user_uentry(user),
        recent_read_entries: Enum.reverse(Reader.list_recent_read_user_uentries(user, 2)),
        trigger_submit: false,
        check_errors: false
      )

    {:noreply, socket}
  end

  def handle_event("key_event", %{"key" => _}, socket) do
    {:noreply, socket}
  end

  defp dformat(timestamp) do
    {:ok, formatted} = Timex.format(DateTime.from_naive!(timestamp, "Etc/UTC"), "{ISOdate} {ISOtime}")
    formatted
  end
end
