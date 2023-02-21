defmodule Garrulus.Reader.UEntry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "uentries" do
    field :read, :boolean, default: false

    belongs_to :entry, Garrulus.Reader.Entry
    belongs_to :user, Garrulus.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(uentry, attrs) do
    uentry
    |> cast(attrs, [:read])
    |> validate_required([:read])
  end
end
