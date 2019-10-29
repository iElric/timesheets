defmodule Timesheets.Repo do
  use Ecto.Repo,
    otp_app: :timesheets,
    adapter: Ecto.Adapters.Postgres
end
