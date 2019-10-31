defmodule Timesheets.SheetsTest do
  use Timesheets.DataCase

  alias Timesheets.Sheets

  describe "sheets" do
    alias Timesheets.Sheets.Sheet

    @valid_attrs %{date: ~D[2010-04-17], status: true}
    @update_attrs %{date: ~D[2011-05-18], status: false}
    @invalid_attrs %{date: nil, status: nil}

    def sheet_fixture(attrs \\ %{}) do
      {:ok, sheet} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Sheets.create_sheet()

      sheet
    end

    test "list_sheets/0 returns all sheets" do
      sheet = sheet_fixture()
      assert Sheets.list_sheets() == [sheet]
    end

    test "get_sheet!/1 returns the sheet with given id" do
      sheet = sheet_fixture()
      assert Sheets.get_sheet!(sheet.id) == sheet
    end

    test "create_sheet/1 with valid data creates a sheet" do
      assert {:ok, %Sheet{} = sheet} = Sheets.create_sheet(@valid_attrs)
      assert sheet.date == ~D[2010-04-17]
      assert sheet.status == true
    end

    test "create_sheet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sheets.create_sheet(@invalid_attrs)
    end

    test "update_sheet/2 with valid data updates the sheet" do
      sheet = sheet_fixture()
      assert {:ok, %Sheet{} = sheet} = Sheets.update_sheet(sheet, @update_attrs)
      assert sheet.date == ~D[2011-05-18]
      assert sheet.status == false
    end

    test "update_sheet/2 with invalid data returns error changeset" do
      sheet = sheet_fixture()
      assert {:error, %Ecto.Changeset{}} = Sheets.update_sheet(sheet, @invalid_attrs)
      assert sheet == Sheets.get_sheet!(sheet.id)
    end

    test "delete_sheet/1 deletes the sheet" do
      sheet = sheet_fixture()
      assert {:ok, %Sheet{}} = Sheets.delete_sheet(sheet)
      assert_raise Ecto.NoResultsError, fn -> Sheets.get_sheet!(sheet.id) end
    end

    test "change_sheet/1 returns a sheet changeset" do
      sheet = sheet_fixture()
      assert %Ecto.Changeset{} = Sheets.change_sheet(sheet)
    end
  end
end
