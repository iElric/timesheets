defmodule Timesheets.Repo.Migrations.ChangePasswordToPasswordHash do
  use Ecto.Migration

  def change do
    alter table("users") do
      remove(:password)
      add :password_hash, :string, default: "", null: false
    end
  end
end
