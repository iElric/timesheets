defmodule Timesheets.Repo.Migrations.MakeDateWorkerIdUnique do
  use Ecto.Migration

  def change do
    create unique_index(:sheets, [:worker_id, :date])
  end
end
