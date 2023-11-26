defmodule Garrulus.Repo.Migrations.EntriesIndexGuid do
  use Ecto.Migration

  def change do
    create index("entries", [:guid])
  end
end
