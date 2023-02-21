defmodule Garrulus.Reader.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscriptions" do
    belongs_to :user, Garrulus.Accounts.User
    belongs_to :feed, Garrulus.Reader.Feed

    timestamps()
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [])
    |> validate_required([])
  end
end
