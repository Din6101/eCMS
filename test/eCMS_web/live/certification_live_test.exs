defmodule ECMSWeb.CertificationLiveTest do
  use ECMSWeb.ConnCase

  import Phoenix.LiveViewTest
  import ECMS.TrainingFixtures

  @create_attrs %{certificate_url: "some certificate_url", issued_at: "2025-09-18T00:48:00Z"}
  @update_attrs %{certificate_url: "some updated certificate_url", issued_at: "2025-09-19T00:48:00Z"}
  @invalid_attrs %{certificate_url: nil, issued_at: nil}

  defp create_certification(_) do
    certification = certification_fixture()
    %{certification: certification}
  end

  describe "Index" do
    setup [:create_certification]

    test "lists all certifications", %{conn: conn, certification: certification} do
      {:ok, _index_live, html} = live(conn, ~p"/certifications")

      assert html =~ "Listing Certifications"
      assert html =~ certification.certificate_url
    end

    test "saves new certification", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/certifications")

      assert index_live |> element("a", "New Certification") |> render_click() =~
               "New Certification"

      assert_patch(index_live, ~p"/certifications/new")

      assert index_live
             |> form("#certification-form", certification: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#certification-form", certification: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/certifications")

      html = render(index_live)
      assert html =~ "Certification created successfully"
      assert html =~ "some certificate_url"
    end

    test "updates certification in listing", %{conn: conn, certification: certification} do
      {:ok, index_live, _html} = live(conn, ~p"/certifications")

      assert index_live |> element("#certifications-#{certification.id} a", "Edit") |> render_click() =~
               "Edit Certification"

      assert_patch(index_live, ~p"/certifications/#{certification}/edit")

      assert index_live
             |> form("#certification-form", certification: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#certification-form", certification: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/certifications")

      html = render(index_live)
      assert html =~ "Certification updated successfully"
      assert html =~ "some updated certificate_url"
    end

    test "deletes certification in listing", %{conn: conn, certification: certification} do
      {:ok, index_live, _html} = live(conn, ~p"/certifications")

      assert index_live |> element("#certifications-#{certification.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#certifications-#{certification.id}")
    end
  end

  describe "Show" do
    setup [:create_certification]

    test "displays certification", %{conn: conn, certification: certification} do
      {:ok, _show_live, html} = live(conn, ~p"/certifications/#{certification}")

      assert html =~ "Show Certification"
      assert html =~ certification.certificate_url
    end

    test "updates certification within modal", %{conn: conn, certification: certification} do
      {:ok, show_live, _html} = live(conn, ~p"/certifications/#{certification}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Certification"

      assert_patch(show_live, ~p"/certifications/#{certification}/show/edit")

      assert show_live
             |> form("#certification-form", certification: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#certification-form", certification: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/certifications/#{certification}")

      html = render(show_live)
      assert html =~ "Certification updated successfully"
      assert html =~ "some updated certificate_url"
    end
  end
end
