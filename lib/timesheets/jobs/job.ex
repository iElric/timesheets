defmodule Timesheets.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jobs" do
    field :budget, :integer
    field :desc, :string
    field :jobcode, :string
    field :name, :string

    belongs_to(:manager, Timesheets.Users.User)
    has_many(:tasks, Timesheets.Tasks.Task)

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:budget, :jobcode, :desc, :name])
    |> validate_required([:budget, :jobcode, :desc, :name])
  end
end
