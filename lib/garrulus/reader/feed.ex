defmodule Garrulus.Reader.Feed do
  use Ecto.Schema
  import Ecto.Changeset

  schema "feeds" do
    field :backoff, :integer
    field :etag, :string
    field :guid, :string
    field :last_failed, :naive_datetime
    field :last_fetched, :naive_datetime
    field :next_fetch, :naive_datetime
    field :title, :string
    field :url, :string

    has_many :entries, Garrulus.Reader.Entry
    has_many :logs, Garrulus.Reader.FetchLog
    many_to_many :users, Garrulus.Accounts.User, join_through: Garrulus.Reader.Subscription

    timestamps()
  end

  @doc false
  def changeset(feed, attrs) do
    feed
    |> cast(attrs, [
      :url,
      :guid,
      :title,
      :last_fetched,
      :last_failed,
      :next_fetch,
      :backoff,
      :etag
    ])
    |> validate_required([
      :url,
      :guid,
      :title,
      :last_fetched,
      :last_failed,
      :next_fetch,
      :backoff,
      :etag
    ])
  end
end
