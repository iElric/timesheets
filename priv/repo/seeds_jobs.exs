alias Timesheets.Repo
alias Timesheets.Jobs.Job

Repo.insert!(%Job{manager_id: 1, budget: 10, jobcode: "JOBA1", desc: "This is JOBA1.", name: "todo1"})
Repo.insert!(%Job{manager_id: 1, budget: 20, jobcode: "JOBB2", desc: "This is JOBb2.", name: "todo2"})

