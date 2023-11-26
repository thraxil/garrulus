defmodule Garrulus.Repo.Migrations.CreateUentries do
  use Ecto.Migration

  def change do
    create table(:uentries) do
      add :read, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :delete_all)
      add :entry_id, references(:entries, on_delete: :delete_all)

      timestamps()
    end

    create index(:uentries, [:user_id])
    create index(:uentries, [:entry_id])
  end
end
