defmodule Timesheets.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      add :password, :string
      add :manager, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:users, [:manager])
  end
end
