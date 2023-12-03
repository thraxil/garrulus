defmodule Garrulus.Repo.Migrations.CreateFetchLogs do
  use Ecto.Migration

  def change do
    create table(:fetch_logs) do
      add :status, :string, default: "ok", null: false
      add :response_status_code, :integer, default: 200, null: true
      add :response_body, :text, default: "", null: true
      add :new_entries, :integer, default: 0
      add :feed_id, references(:feeds, on_delete: :delete_all)

      timestamps()
    end

    create index(:fetch_logs, [:feed_id])
  end
end
