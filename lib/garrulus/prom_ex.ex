defmodule Garrulus.PromEx do
  @moduledoc """
  4. Update the list of plugins in the `plugins/0` function return list to reflect your
     application's dependencies. Also update the list of dashboards that are to be uploaded
     to Grafana in the `dashboards/0` function.
  """

  use PromEx, otp_app: :garrulus

  alias PromEx.Plugins

  @impl true
  def plugins do
    [
      # PromEx built in plugins
      Plugins.Application,
      Plugins.Beam,
      {Plugins.Phoenix, router: GarrulusWeb.Router, endpoint: GarrulusWeb.Endpoint},
      Plugins.Ecto,
      # Plugins.Oban,
      Plugins.PhoenixLiveView,
      # Plugins.Absinthe,
      # Plugins.Broadway,

      # Add your own PromEx metrics plugins
      Garrulus.PromExPlugin
    ]
  end

  @impl true
  def dashboard_assigns do
    [
      datasource_id: "garrulus",
      default_selected_interval: "30s"
    ]
  end

  @impl true
  def dashboards do
    [
      # PromEx built in Grafana dashboards
      {:prom_ex, "application.json"},
      {:prom_ex, "beam.json"}
      # {:prom_ex, "phoenix.json"},
      # {:prom_ex, "ecto.json"},
      # {:prom_ex, "oban.json"},
      # {:prom_ex, "phoenix_live_view.json"},
      # {:prom_ex, "absinthe.json"},
      # {:prom_ex, "broadway.json"},

      # Add your dashboard definitions here with the format: {:otp_app, "path_in_priv"}
      # {:garrulus, "/grafana_dashboards/user_metrics.json"}
    ]
  end
end

defmodule Garrulus.PromExPlugin do
  use PromEx.Plugin
  alias Garrulus.Reader

  @impl true
  def polling_metrics(opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    poll_rate = Keyword.get(opts, :poll_rate, 61_000)
    metric_prefix = Keyword.get(opts, :metric_prefix, PromEx.metric_prefix(otp_app, :reader))

    [
      Polling.build(
        :reader_feeds_count,
        poll_rate,
        {__MODULE__, :feeds_count, []},
        [
          last_value(
            metric_prefix ++ [:feeds, :total],
            event_name: [:prom_ex, :plugin, :reader, :feeds, :count],
            description: "Total number of feeds",
            measurement: :count,
            unit: :count
          )
        ]
      ),
      Polling.build(
        :reader_subscriptions_count,
        poll_rate,
        {__MODULE__, :subscriptions_count, []},
        [
          last_value(
            metric_prefix ++ [:subscriptions, :total],
            event_name: [:prom_ex, :plugin, :reader, :subscriptions, :count],
            description: "Total number of subscriptions",
            measurement: :count,
            unit: :count
          )
        ]
      ),
      Polling.build(
        :reader_entries_count,
        poll_rate,
        {__MODULE__, :entries_count, []},
        [
          last_value(
            metric_prefix ++ [:entries, :total],
            event_name: [:prom_ex, :plugin, :reader, :entries, :count],
            description: "Total number of entries",
            measurement: :count,
            unit: :count
          )
        ]
      ),
      Polling.build(
        :reader_uentries_count,
        poll_rate,
        {__MODULE__, :uentries_count, []},
        [
          last_value(
            metric_prefix ++ [:uentries, :total],
            event_name: [:prom_ex, :plugin, :reader, :uentries, :count],
            description: "Total number of UEntries",
            measurement: :count,
            unit: :count
          )
        ]
      ),
      Polling.build(
        :reader_fetchlogs_count,
        poll_rate,
        {__MODULE__, :fetchlogs_count, []},
        [
          last_value(
            metric_prefix ++ [:fetchlogs, :total],
            event_name: [:prom_ex, :plugin, :reader, :fetchlogs, :count],
            description: "Total number of fetchlogs",
            measurement: :count,
            unit: :count
          )
        ]
      )
    ]
  end

  @doc false
  def feeds_count do
    cnt = Reader.feeds_count()
    :telemetry.execute([:prom_ex, :plugin, :reader, :feeds, :count], %{count: cnt})
  end

  @doc false
  def subscriptions_count do
    cnt = Reader.subscriptions_count()
    :telemetry.execute([:prom_ex, :plugin, :reader, :subscriptions, :count], %{count: cnt})
  end

  @doc false
  def entries_count do
    cnt = Reader.entries_count()
    :telemetry.execute([:prom_ex, :plugin, :reader, :entries, :count], %{count: cnt})
  end

  @doc false
  def uentries_count do
    cnt = Reader.uentries_count()
    :telemetry.execute([:prom_ex, :plugin, :reader, :uentries, :count], %{count: cnt})
  end

  @doc false
  def fetchlogs_count do
    cnt = Reader.fetchlogs_count()
    :telemetry.execute([:prom_ex, :plugin, :reader, :fetchlogs, :count], %{count: cnt})
  end
end
