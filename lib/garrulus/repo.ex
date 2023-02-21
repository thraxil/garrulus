defmodule Garrulus.Repo do
  use Ecto.Repo,
    otp_app: :garrulus,
    adapter: Ecto.Adapters.Postgres
end
