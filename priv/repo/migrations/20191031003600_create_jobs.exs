defmodule Timesheets.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :budget, :integer
      add :jobcode, :string
      add :desc, :text
      add :name, :string
      add :manager_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:jobs, [:manager_id])
  end
end
