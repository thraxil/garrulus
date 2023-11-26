defmodule Garrulus.Reader.Fetcher do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    # Do the work you desire here
    due = Garrulus.Reader.due_feeds()
    Enum.each(due, fn f -> Garrulus.Reader.Worker.fetch_feed(f) end)
    # Reschedule once more
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    one_minute = 60 * 1000
    # 10% jitter
    jitter = :rand.uniform(floor(one_minute / 10))
    Process.send_after(self(), :work, one_minute + jitter)
    # expunge uentries
    # remove duplicate feeds
  end
end
