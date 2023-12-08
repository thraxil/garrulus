defmodule Garrulus.Reader.Fetcher do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_fetch_feeds()
    {:ok, state}
  end

  def handle_info(:fetch_feeds, state) do
    due = Garrulus.Reader.due_feeds()
    Enum.each(due, fn f -> Garrulus.Reader.Worker.fetch_feed(f) end)
    schedule_fetch_feeds()
    {:noreply, state}
  end

  defp schedule_fetch_feeds() do
    one_minute = 60 * 1000
    jitter = :rand.uniform(floor(one_minute / 10))
    Process.send_after(self(), :fetch_feeds, one_minute + jitter)
  end
end
