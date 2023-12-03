defmodule Garrulus.Reader.FetchLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "fetch_logs" do
    field :status, Ecto.Enum, values: [:ok, :failed, :skipped]
    field :response_body, :string
    field :response_status_code, :integer
    field :new_entries, :integer

    belongs_to :feed, Garrulus.Reader.Feed

    timestamps()
  end

  @doc false
  def changeset(fetch_log, attrs) do
    fetch_log
    |> cast(attrs, [:status, :response_status_code, :response_body, :new_entries])
    |> validate_required([:status, :response_status_code, :response_body, :new_entries])
  end
end
