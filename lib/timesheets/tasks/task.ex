defmodule Timesheets.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :desc, :string
    field :spent_hours, :integer

    belongs_to(:job, Timesheets.Jobs.Job)
    belongs_to(:sheet, Timesheets.Sheets.Sheet)

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:spent_hours, :desc])
    |> validate_required([:spent_hours, :desc])
  end
end
