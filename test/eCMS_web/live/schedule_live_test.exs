defmodule ECMSWeb.ScheduleLiveTest do
  use ECMSWeb.ConnCase

  import Phoenix.LiveViewTest
  import ECMS.TrainingFixtures

  @create_attrs %{status: "some status", notes: "some notes"}
  @update_attrs %{status: "some updated status", notes: "some updated notes"}
  @invalid_attrs %{status: nil, notes: nil}

  defp create_schedule(_) do
    schedule = schedule_fixture()
    %{schedule: schedule}
  end

  describe "Index" do
    setup [:create_schedule]

    test "lists all schedules", %{conn: conn, schedule: schedule} do
      {:ok, _index_live, html} = live(conn, ~p"/schedules")

      assert html =~ "Listing Schedules"
      assert html =~ schedule.status
    end

    test "saves new schedule", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/schedules")

      assert index_live |> element("a", "New Schedule") |> render_click() =~
               "New Schedule"

      assert_patch(index_live, ~p"/schedules/new")

      assert index_live
             |> form("#schedule-form", schedule: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#schedule-form", schedule: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/schedules")

      html = render(index_live)
      assert html =~ "Schedule created successfully"
      assert html =~ "some status"
    end

    test "updates schedule in listing", %{conn: conn, schedule: schedule} do
      {:ok, index_live, _html} = live(conn, ~p"/schedules")

      assert index_live |> element("#schedules-#{schedule.id} a", "Edit") |> render_click() =~
               "Edit Schedule"

      assert_patch(index_live, ~p"/schedules/#{schedule}/edit")

      assert index_live
             |> form("#schedule-form", schedule: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#schedule-form", schedule: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/schedules")

      html = render(index_live)
      assert html =~ "Schedule updated successfully"
      assert html =~ "some updated status"
    end

    test "deletes schedule in listing", %{conn: conn, schedule: schedule} do
      {:ok, index_live, _html} = live(conn, ~p"/schedules")

      assert index_live |> element("#schedules-#{schedule.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#schedules-#{schedule.id}")
    end
  end

  describe "Show" do
    setup [:create_schedule]

    test "displays schedule", %{conn: conn, schedule: schedule} do
      {:ok, _show_live, html} = live(conn, ~p"/schedules/#{schedule}")

      assert html =~ "Show Schedule"
      assert html =~ schedule.status
    end

    test "updates schedule within modal", %{conn: conn, schedule: schedule} do
      {:ok, show_live, _html} = live(conn, ~p"/schedules/#{schedule}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Schedule"

      assert_patch(show_live, ~p"/schedules/#{schedule}/show/edit")

      assert show_live
             |> form("#schedule-form", schedule: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#schedule-form", schedule: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/schedules/#{schedule}")

      html = render(show_live)
      assert html =~ "Schedule updated successfully"
      assert html =~ "some updated status"
    end
  end
end
