defmodule GarrulusWeb.EntriesLive do
  use GarrulusWeb, :live_view
  alias Garrulus.Accounts
  alias Garrulus.Reader

  @preview_entries 10
  @review_entries 2

  defp get_entries(user, read_offset \\ 0) do
    unread = Reader.list_unread_user_uentries(user, @preview_entries)

    read =
      Enum.reverse(Reader.list_recent_read_user_uentries(user, @review_entries + read_offset))

    %{
      unread_entries: unread,
      unread_entries_count: Reader.count_unread_user_uentries(user),
      current_entry: Reader.get_current_user_uentry(user),
      prev_read_entries: read,
      next_read_entries: [],
      read_offset: read_offset
    }
  end

  defp fresh_data(socket, user) do
    entries = get_entries(user)

    socket
    |> assign(
      upcoming_entries: entries.unread_entries,
      unread_entries_count: entries.unread_entries_count,
      current_entry: entries.current_entry,
      prev_read_entries: entries.prev_read_entries,
      next_read_entries: entries.next_read_entries,
      read_offset: entries.read_offset
    )
  end

  def mount(_params, %{"user_token" => user_token}, socket) do
    user = Accounts.get_user_by_session_token(user_token)

    socket =
      socket
      |> assign(:current_user, Accounts.get_user_by_session_token(user_token))
      |> fresh_data(user)

    {:ok, socket, temporary_assigns: []}
  end

  def handle_event("key_event", %{"key" => "j", "uentry_id" => id}, socket) do
    %{assigns: %{current_user: user}} = socket
    uentry = Reader.get_uentry!(id)
    Reader.update_uentry(uentry, %{read: true})
    {:noreply, socket |> fresh_data(user)}
  end

  def handle_event("key_event", %{"key" => "k", "uentry_id" => _id}, socket) do
    %{assigns: %{current_user: user}} = socket
    {:noreply, socket |> fresh_data(user)}
  end

  def handle_event("key_event", %{"key" => _}, socket) do
    {:noreply, socket}
  end

  defp dformat(timestamp) do
    {:ok, formatted} =
      Timex.format(DateTime.from_naive!(timestamp, "Etc/UTC"), "{ISOdate} {ISOtime}")

    formatted
  end
end
