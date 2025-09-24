defmodule ECMSWeb.LiveEventLiveTest do
  use ECMSWeb.ConnCase

  import Phoenix.LiveViewTest
  import ECMS.TrainingFixtures

  @create_attrs %{title: "some title", live: true, presenter: "some presenter"}
  @update_attrs %{title: "some updated title", live: false, presenter: "some updated presenter"}
  @invalid_attrs %{title: nil, live: false, presenter: nil}

  defp create_live_event(_) do
    live_event = live_event_fixture()
    %{live_event: live_event}
  end

  describe "Index" do
    setup [:create_live_event]

    test "lists all live_events", %{conn: conn, live_event: live_event} do
      {:ok, _index_live, html} = live(conn, ~p"/live_events")

      assert html =~ "Listing Live events"
      assert html =~ live_event.title
    end

    test "saves new live_event", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/live_events")

      assert index_live |> element("a", "New Live event") |> render_click() =~
               "New Live event"

      assert_patch(index_live, ~p"/live_events/new")

      assert index_live
             |> form("#live_event-form", live_event: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#live_event-form", live_event: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/live_events")

      html = render(index_live)
      assert html =~ "Live event created successfully"
      assert html =~ "some title"
    end

    test "updates live_event in listing", %{conn: conn, live_event: live_event} do
      {:ok, index_live, _html} = live(conn, ~p"/live_events")

      assert index_live |> element("#live_events-#{live_event.id} a", "Edit") |> render_click() =~
               "Edit Live event"

      assert_patch(index_live, ~p"/live_events/#{live_event}/edit")

      assert index_live
             |> form("#live_event-form", live_event: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#live_event-form", live_event: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/live_events")

      html = render(index_live)
      assert html =~ "Live event updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes live_event in listing", %{conn: conn, live_event: live_event} do
      {:ok, index_live, _html} = live(conn, ~p"/live_events")

      assert index_live |> element("#live_events-#{live_event.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#live_events-#{live_event.id}")
    end
  end

  describe "Show" do
    setup [:create_live_event]

    test "displays live_event", %{conn: conn, live_event: live_event} do
      {:ok, _show_live, html} = live(conn, ~p"/live_events/#{live_event}")

      assert html =~ "Show Live event"
      assert html =~ live_event.title
    end

    test "updates live_event within modal", %{conn: conn, live_event: live_event} do
      {:ok, show_live, _html} = live(conn, ~p"/live_events/#{live_event}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Live event"

      assert_patch(show_live, ~p"/live_events/#{live_event}/show/edit")

      assert show_live
             |> form("#live_event-form", live_event: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#live_event-form", live_event: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/live_events/#{live_event}")

      html = render(show_live)
      assert html =~ "Live event updated successfully"
      assert html =~ "some updated title"
    end
  end
end
