defmodule Timesheets.Sheets.Sheet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sheets" do
    field :date, :date
    field :status, :boolean, default: false

    has_many(:tasks, Timesheets.Tasks.Task)
    belongs_to(:worker, Timesheets.Users.User)

    timestamps()
  end

  @doc false
  def changeset(sheet, attrs) do
    sheet
    |> cast(attrs, [:status, :date, :worker_id])
    |> validate_required([:status, :date, :worker_id])
  end
end
