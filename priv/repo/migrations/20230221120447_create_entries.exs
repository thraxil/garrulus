defmodule Garrulus.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :guid, :string
      add :title, :string
      add :link, :string
      add :description, :text
      add :author, :string
      add :published, :naive_datetime
      add :feed_id, references(:feeds, on_delete: :nothing)

      timestamps()
    end

    create index(:entries, [:feed_id])
  end
end
