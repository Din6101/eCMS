defmodule ECMSWeb.EnrollmentLiveTest do
  use ECMSWeb.ConnCase

  import Phoenix.LiveViewTest
  import ECMS.TrainingFixtures

  @create_attrs %{status: "some status", progress: 42, user_id: "some user_id", course_id: "some course_id", milestone: %{}}
  @update_attrs %{status: "some updated status", progress: 43, user_id: "some updated user_id", course_id: "some updated course_id", milestone: %{}}
  @invalid_attrs %{status: nil, progress: nil, user_id: nil, course_id: nil, milestone: nil}

  defp create_enrollment(_) do
    enrollment = enrollment_fixture()
    %{enrollment: enrollment}
  end

  describe "Index" do
    setup [:create_enrollment]

    test "lists all enrollments", %{conn: conn, enrollment: enrollment} do
      {:ok, _index_live, html} = live(conn, ~p"/enrollments")

      assert html =~ "Listing Enrollments"
      assert html =~ enrollment.status
    end

    test "saves new enrollment", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/enrollments")

      assert index_live |> element("a", "New Enrollment") |> render_click() =~
               "New Enrollment"

      assert_patch(index_live, ~p"/enrollments/new")

      assert index_live
             |> form("#enrollment-form", enrollment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#enrollment-form", enrollment: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/enrollments")

      html = render(index_live)
      assert html =~ "Enrollment created successfully"
      assert html =~ "some status"
    end

    test "updates enrollment in listing", %{conn: conn, enrollment: enrollment} do
      {:ok, index_live, _html} = live(conn, ~p"/enrollments")

      assert index_live |> element("#enrollments-#{enrollment.id} a", "Edit") |> render_click() =~
               "Edit Enrollment"

      assert_patch(index_live, ~p"/enrollments/#{enrollment}/edit")

      assert index_live
             |> form("#enrollment-form", enrollment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#enrollment-form", enrollment: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/enrollments")

      html = render(index_live)
      assert html =~ "Enrollment updated successfully"
      assert html =~ "some updated status"
    end

    test "deletes enrollment in listing", %{conn: conn, enrollment: enrollment} do
      {:ok, index_live, _html} = live(conn, ~p"/enrollments")

      assert index_live |> element("#enrollments-#{enrollment.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#enrollments-#{enrollment.id}")
    end
  end

  describe "Show" do
    setup [:create_enrollment]

    test "displays enrollment", %{conn: conn, enrollment: enrollment} do
      {:ok, _show_live, html} = live(conn, ~p"/enrollments/#{enrollment}")

      assert html =~ "Show Enrollment"
      assert html =~ enrollment.status
    end

    test "updates enrollment within modal", %{conn: conn, enrollment: enrollment} do
      {:ok, show_live, _html} = live(conn, ~p"/enrollments/#{enrollment}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Enrollment"

      assert_patch(show_live, ~p"/enrollments/#{enrollment}/show/edit")

      assert show_live
             |> form("#enrollment-form", enrollment: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#enrollment-form", enrollment: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/enrollments/#{enrollment}")

      html = render(show_live)
      assert html =~ "Enrollment updated successfully"
      assert html =~ "some updated status"
    end
  end
end
