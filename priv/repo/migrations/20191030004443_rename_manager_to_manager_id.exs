defmodule Timesheets.Repo.Migrations.RenameManagerToManagerId do
  use Ecto.Migration

  def change do
    rename(table("users"), :manager, to: :manager_id)

  end
end
