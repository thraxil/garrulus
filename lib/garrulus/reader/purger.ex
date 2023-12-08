defmodule Garrulus.Reader.Purger do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_purge_uentries()
    {:ok, state}
  end

  def handle_info(:purge_uentries, state) do
    Garrulus.Reader.purge_uentries()
    schedule_purge_uentries()
    {:noreply, state}
  end

  defp schedule_purge_uentries() do
    one_hour = 60 * 60 * 1000
    jitter = :rand.uniform(floor(one_hour / 10))
    Process.send_after(self(), :purge_uentries, one_hour + jitter)
  end
end
