defmodule TimesheetsWeb.SheetController do
  use TimesheetsWeb, :controller

  alias Timesheets.Sheets
  alias Timesheets.Sheets.Sheet

  def index(conn, _params) do
    sheets = Sheets.list_sheets()
    render(conn, "index.html", sheets: sheets)
  end

  def new(conn, _params) do
    changeset = Sheets.change_sheet(%Sheet{})
    render(conn, "new.html", changeset: changeset)
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
        "desc8" => desc8
      }) do
    hours = [hours1, hours2, hours3, hours4, hours5, hours6, hours7, hours8]
    jobcodes = [jodcode1, jodcode2, jodcode3, jodcode4, jodcode5, jodcode6, jodcode7, jodcode8]
    descs = [desc1, desc2, desc3, desc4, desc5, desc6, desc7, desc8]
    # map hours from string to in
    # filer to have only int greater than 0
    hours =
      Enum.map(hours, fn h ->
        if h === "" do
          0
        else
          # TODO: deal with parse error later
          {h, _} = Integer.parse(h)
          h
        end
      end)

    total_hours = Enum.reduce(hours, 0, fn h, acc -> h + acc end)

    if total_hours === 8 do
      current_user = conn.assigns.current_user.id
      # insert a sheet first
      {:ok, sheet} =
        Timesheets.Sheets.create_sheet(%{worker_id: current_user, date: Date.utc_today(), status: false})

      # insert these tasks
      job_ids = Enum.map(jobcodes, fn jobcode -> Timesheets.Jobs.get_job_id_by_jobcode(jobcode) end)
      itr = Enum.zip(hours, job_ids)
      itr = Enum.zip(itr, descs)

      Enum.map(itr, fn {{hour, job_id}, desc} ->
        if hour > 0 do
          Timesheets.Tasks.create_task(%{
            spent_hours: hour,
            desc: desc,
            job_id: job_id,
            sheet_id: sheet.id
          })
        end
      end)

      # substract hours in job
      # TODO: move to manager page
      Enum.map(itr, fn {{hour, job_id}, _} ->
        if hour > 0 do
          Timesheets.Jobs.update_job(Timesheets.Jobs.get_job!(job_id), %{budget: Timesheets.Jobs.get_budget(job_id) - hour})
        end
      end)
      render(conn, "show.html")
    else

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

  def show(conn, %{"id" => id}) do
    sheet = Sheets.get_sheet!(id)
    render(conn, "show.html", sheet: sheet)
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
