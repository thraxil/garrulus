defmodule Garrulus.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :user_id, references(:users, on_delete: :nothing)
      add :feed_id, references(:feeds, on_delete: :nothing)

      timestamps()
    end

    create index(:subscriptions, [:user_id])
    create index(:subscriptions, [:feed_id])
  end
end
