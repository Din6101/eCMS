defmodule ECMSWeb.ActivitiesLiveTest do
  use ECMSWeb.ConnCase

  import Phoenix.LiveViewTest
  import ECMS.TrainingFixtures

  @create_attrs %{date: "2025-09-15", time: "14:00", description: "some description"}
  @update_attrs %{date: "2025-09-16", time: "15:01", description: "some updated description"}
  @invalid_attrs %{date: nil, time: nil, description: nil}

  defp create_activities(_) do
    activities = activities_fixture()
    %{activities: activities}
  end

  describe "Index" do
    setup [:create_activities]

    test "lists all activity", %{conn: conn, activities: activities} do
      {:ok, _index_live, html} = live(conn, ~p"/activity")

      assert html =~ "Listing Activity"
      assert html =~ activities.description
    end

    test "saves new activities", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/activity")

      assert index_live |> element("a", "New Activities") |> render_click() =~
               "New Activities"

      assert_patch(index_live, ~p"/activity/new")

      assert index_live
             |> form("#activities-form", activities: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#activities-form", activities: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/activity")

      html = render(index_live)
      assert html =~ "Activities created successfully"
      assert html =~ "some description"
    end

    test "updates activities in listing", %{conn: conn, activities: activities} do
      {:ok, index_live, _html} = live(conn, ~p"/activity")

      assert index_live |> element("#activity-#{activities.id} a", "Edit") |> render_click() =~
               "Edit Activities"

      assert_patch(index_live, ~p"/activity/#{activities}/edit")

      assert index_live
             |> form("#activities-form", activities: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#activities-form", activities: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/activity")

      html = render(index_live)
      assert html =~ "Activities updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes activities in listing", %{conn: conn, activities: activities} do
      {:ok, index_live, _html} = live(conn, ~p"/activity")

      assert index_live |> element("#activity-#{activities.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#activity-#{activities.id}")
    end
  end

  describe "Show" do
    setup [:create_activities]

    test "displays activities", %{conn: conn, activities: activities} do
      {:ok, _show_live, html} = live(conn, ~p"/activity/#{activities}")

      assert html =~ "Show Activities"
      assert html =~ activities.description
    end

    test "updates activities within modal", %{conn: conn, activities: activities} do
      {:ok, show_live, _html} = live(conn, ~p"/activity/#{activities}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Activities"

      assert_patch(show_live, ~p"/activity/#{activities}/show/edit")

      assert show_live
             |> form("#activities-form", activities: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#activities-form", activities: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/activity/#{activities}")

      html = render(show_live)
      assert html =~ "Activities updated successfully"
      assert html =~ "some updated description"
    end
  end
end
