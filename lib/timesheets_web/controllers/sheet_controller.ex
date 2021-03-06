defmodule TimesheetsWeb.SheetController do
  use TimesheetsWeb, :controller

  alias Timesheets.Sheets
  alias Timesheets.Sheets.Sheet

  defp date_range_to_string_list() do
    Date.range(~D[2019-09-01], Date.utc_today())
    |> Enum.map(fn d -> Date.to_string(d) end)
    |> Enum.reverse()
  end

  def subtract(conn, %{"sheet_id" => sheet_id}) do
    # change the corresponding sheet status
    Timesheets.Sheets.update_sheet(Timesheets.Sheets.get_sheet!(sheet_id), %{status: true})
    # subtract the task hours in job
    tasks = Timesheets.Tasks.get_tasks_by_sheet_id(sheet_id)
    itr = Enum.map(tasks, fn t -> {t.spent_hours, t.job_id} end)

    Enum.map(itr, fn {hour, job_id} ->
      Timesheets.Jobs.update_job(Timesheets.Jobs.get_job!(job_id), %{
        budget: Timesheets.Jobs.get_budget(job_id) - hour
      })
    end)

    render(conn, "success.html")
  end

  def approve(conn, %{"worker" => worker, "date" => date}) do
    date_string = date
    {:ok, date} = Date.from_iso8601(date)
    worker_id = Timesheets.Users.get_id_by_name(worker)
    status = Timesheets.Sheets.get_status_by_worker_id_date(worker_id, date)
    sheet_id = Timesheets.Sheets.get_id_by_worker_id_date(worker_id, date)

    tasks =
      if is_nil(sheet_id) do
        []
      else
        Timesheets.Tasks.get_tasks_by_sheet_id(sheet_id)
      end

    render(conn, "approve.html",
      tasks: tasks,
      status: status,
      date: date_string,
      worker: worker,
      sheet_id: sheet_id
    )
  end

  def index(conn, _params) do
    current_user = conn.assigns.current_user.id
    worker_names = Timesheets.Users.get_worker_names_by_manager_id(current_user)
    render(conn, "index.html", worker_names: worker_names, dates: date_range_to_string_list())
  end

  def new(conn, %{"date" => date}) do
    {:ok, date} = Date.from_iso8601(date)
    current_user = conn.assigns.current_user.id
    status = Timesheets.Sheets.get_status_by_worker_id_date(current_user, date)
    sheet_id = Timesheets.Sheets.get_id_by_worker_id_date(current_user, date)
    IO.inspect(date)
    IO.inspect(status)
    IO.inspect(sheet_id)

    tasks =
      if is_nil(sheet_id) do
        []
      else
        Timesheets.Tasks.get_tasks_by_sheet_id(sheet_id)
      end

    IO.inspect(tasks)
    render(conn, "new.html", tasks: tasks, status: status, dates: date_range_to_string_list())
  end

  def new(conn, _params) do
    render(conn, "new.html", tasks: [], status: false, dates: date_range_to_string_list())
  end

  # this is not elegant at all, but seems this is the only way
  def create(conn, %{
        "hours1" => hours1,
        "hours2" => hours2,
        "hours3" => hours3,
        "hours4" => hours4,
        "hours5" => hours5,
        "hours6" => hours6,
        "hours7" => hours7,
        "hours8" => hours8,
        "jobcode1" => jodcode1,
        "jobcode2" => jodcode2,
        "jobcode3" => jodcode3,
        "jobcode4" => jodcode4,
        "jobcode5" => jodcode5,
        "jobcode6" => jodcode6,
        "jobcode7" => jodcode7,
        "jobcode8" => jodcode8,
        "desc1" => desc1,
        "desc2" => desc2,
        "desc3" => desc3,
        "desc4" => desc4,
        "desc5" => desc5,
        "desc6" => desc6,
        "desc7" => desc7,
        "desc8" => desc8,
        "date" => date
      }) do
    hours = [hours1, hours2, hours3, hours4, hours5, hours6, hours7, hours8]
    jobcodes = [jodcode1, jodcode2, jodcode3, jodcode4, jodcode5, jodcode6, jodcode7, jodcode8]
    descs = [desc1, desc2, desc3, desc4, desc5, desc6, desc7, desc8]
    {_, date} = Date.from_iso8601(date)
    # map hours from string to in
    # filer to have only int greater than 0
    hours =
      Enum.map(hours, fn h ->
        if h === "" do
          0
        else
          # if the input is float, only count the integer part, if is other string, count as 0
          case Integer.parse(h) do
            :error ->
              0

            {h, _} ->
              if h < 0 do
                0
              else
                h
              end
          end
        end
      end)

    total_hours = Enum.reduce(hours, 0, fn h, acc -> h + acc end)

    if total_hours === 8 do
      current_user = conn.assigns.current_user.id

      {ok_or_error, sheet_or_info} =
        Timesheets.Sheets.create_sheet(%{
          worker_id: current_user,
          date: date,
          status: false
        })

      # this sheet not exist
      if ok_or_error === :ok do
        # insert these tasks
        job_ids =
          Enum.map(jobcodes, fn jobcode -> Timesheets.Jobs.get_job_id_by_jobcode(jobcode) end)

        itr = Enum.zip(hours, job_ids)
        itr = Enum.zip(itr, descs)

        Enum.map(itr, fn {{hour, job_id}, desc} ->
          if hour > 0 do
            desc =
              if desc === "" do
                "No description"
              else
                desc
              end

            Timesheets.Tasks.create_task(%{
              spent_hours: hour,
              desc: desc,
              job_id: job_id,
              sheet_id: sheet_or_info.id
            })
          end
        end)

        render(conn, "new.html", tasks: [], status: false, dates: date_range_to_string_list())
      else
        # this sheet exist
        conn
        |> put_flash(:info, sheet_or_info)
        |> redirect(to: Routes.task_path(conn, :create))
      end
    else
      conn
      |> put_flash(:info, "All the hours of tasks should add up to 8")
      |> redirect(to: Routes.task_path(conn, :create))
    end
  end

  def create(conn, %{"sheet" => sheet_params}) do
    case Sheets.create_sheet(sheet_params) do
      {:ok, sheet} ->
        conn
        |> put_flash(:info, "Sheet created successfully.")
        |> redirect(to: Routes.sheet_path(conn, :show, sheet))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"date" => date}) do
    date = Date.from_iso8601(date)
    current_user = conn.assigns.current_user.id
    status = Timesheets.Sheets.get_status_by_worker_id_date(current_user, date)
    sheet_id = Timesheets.Sheets.get_id_by_worker_id_date(current_user, date)
    tasks = Timesheets.Tasks.get_tasks_by_sheet_id(sheet_id)
    render(conn, "show.html", tasks: tasks, status: status, dates: date_range_to_string_list())
  end

  def edit(conn, %{"id" => id}) do
    sheet = Sheets.get_sheet!(id)
    changeset = Sheets.change_sheet(sheet)
    render(conn, "edit.html", sheet: sheet, changeset: changeset)
  end

  def update(conn, %{"id" => id, "sheet" => sheet_params}) do
    sheet = Sheets.get_sheet!(id)

    case Sheets.update_sheet(sheet, sheet_params) do
      {:ok, sheet} ->
        conn
        |> put_flash(:info, "Sheet updated successfully.")
        |> redirect(to: Routes.sheet_path(conn, :show, sheet))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", sheet: sheet, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    sheet = Sheets.get_sheet!(id)
    {:ok, _sheet} = Sheets.delete_sheet(sheet)

    conn
    |> put_flash(:info, "Sheet deleted successfully.")
    |> redirect(to: Routes.sheet_path(conn, :index))
  end
end
