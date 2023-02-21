defmodule Garrulus.Repo.Migrations.CreateFeeds do
  use Ecto.Migration

  def change do
    create table(:feeds) do
      add :url, :string
      add :guid, :string
      add :title, :string
      add :last_fetched, :naive_datetime
      add :last_failed, :naive_datetime
      add :next_fetch, :naive_datetime
      add :backoff, :integer
      add :etag, :string

      timestamps()
    end
  end
end
