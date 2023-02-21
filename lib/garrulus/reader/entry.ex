defmodule Garrulus.Reader.Entry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "entries" do
    field :author, :string
    field :description, :string
    field :guid, :string
    field :link, :string
    field :published, :naive_datetime
    field :title, :string

    belongs_to :feed, Garrulus.Reader.Feed

    has_many :uentries, Garrulus.Reader.UEntry

    timestamps()
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, [:guid, :title, :link, :description, :author, :published])
    |> validate_required([:guid, :title, :link, :description, :author, :published])
  end
end
