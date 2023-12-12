defmodule HealthCheck do
  import Plug.Conn

  def init(opts), do: opts

  # mainly for backward compatability with existing monitoring
  def call(%Plug.Conn{request_path: "/smoketest/"} = conn, _opts) do
    conn
    |> send_resp(200, "PASS")
    |> halt()
  end

  def call(%Plug.Conn{request_path: "/smoketest"} = conn, _opts) do
    conn
    |> send_resp(200, "PASS")
    |> halt()
  end

  def call(%Plug.Conn{request_path: "/healthz"} = conn, _opts) do
    conn
    |> send_resp(200, "")
    |> halt()
  end

  def call(conn, _opts), do: conn
end
