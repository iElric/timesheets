# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Timesheets.Repo.insert!(%Timesheets.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Timesheets.Repo
alias Timesheets.Users.User
alias Timesheets.Repo
alias Timesheets.Jobs.Job

pw = Argon2.hash_pwd_salt("password123456")

Repo.insert!(%User{name: "Alice Anderson", email: "alice@acme.com", password_hash: pw})
Repo.insert!(%User{name: "Bob Anderson", email: "bob@acme.com", password_hash: pw, manager_id: 1})
Repo.insert!(%User{name: "Carol Anderson", email: "carol@acme.com", password_hash: pw, manager_id: 1})
Repo.insert!(%User{name: "Dave Anderson", email: "dave@acme.com", password_hash: pw, manager_id: 1})
Repo.insert!(%Job{manager_id: 1, budget: 20, jobcode: "VAOR-01", desc: "hard to do", name: "Cyborg Arm"})
Repo.insert!(%Job{manager_id: 1, budget: 45, jobcode: "VAOR-02", desc: "easy", name: "Sobriety Pill"})




