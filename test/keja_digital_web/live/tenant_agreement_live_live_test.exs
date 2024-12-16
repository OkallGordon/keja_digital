defmodule KejaDigitalWeb.TenantAgreementLiveLiveTest do
  use KejaDigitalWeb.ConnCase

  import Phoenix.LiveViewTest
  import KejaDigital.AgreementsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_tenant_agreement_live(_) do
    tenant_agreement_live = tenant_agreement_live_fixture()
    %{tenant_agreement_live: tenant_agreement_live}
  end

  describe "Index" do
    setup [:create_tenant_agreement_live]

    test "lists all tenant_agreements", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/tenant_agreements")

      assert html =~ "Listing Tenant agreements"
    end

    test "saves new tenant_agreement_live", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/tenant_agreements")

      assert index_live |> element("a", "New Tenant agreement live") |> render_click() =~
               "New Tenant agreement live"

      assert_patch(index_live, ~p"/tenant_agreements/new")

      assert index_live
             |> form("#tenant_agreement_live-form", tenant_agreement_live: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#tenant_agreement_live-form", tenant_agreement_live: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tenant_agreements")

      html = render(index_live)
      assert html =~ "Tenant agreement live created successfully"
    end

    test "updates tenant_agreement_live in listing", %{conn: conn, tenant_agreement_live: tenant_agreement_live} do
      {:ok, index_live, _html} = live(conn, ~p"/tenant_agreements")

      assert index_live |> element("#tenant_agreements-#{tenant_agreement_live.id} a", "Edit") |> render_click() =~
               "Edit Tenant agreement live"

      assert_patch(index_live, ~p"/tenant_agreements/#{tenant_agreement_live}/edit")

      assert index_live
             |> form("#tenant_agreement_live-form", tenant_agreement_live: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#tenant_agreement_live-form", tenant_agreement_live: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/tenant_agreements")

      html = render(index_live)
      assert html =~ "Tenant agreement live updated successfully"
    end

    test "deletes tenant_agreement_live in listing", %{conn: conn, tenant_agreement_live: tenant_agreement_live} do
      {:ok, index_live, _html} = live(conn, ~p"/tenant_agreements")

      assert index_live |> element("#tenant_agreements-#{tenant_agreement_live.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#tenant_agreements-#{tenant_agreement_live.id}")
    end
  end

  describe "Show" do
    setup [:create_tenant_agreement_live]

    test "displays tenant_agreement_live", %{conn: conn, tenant_agreement_live: tenant_agreement_live} do
      {:ok, _show_live, html} = live(conn, ~p"/tenant_agreements/#{tenant_agreement_live}")

      assert html =~ "Show Tenant agreement live"
    end

    test "updates tenant_agreement_live within modal", %{conn: conn, tenant_agreement_live: tenant_agreement_live} do
      {:ok, show_live, _html} = live(conn, ~p"/tenant_agreements/#{tenant_agreement_live}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Tenant agreement live"

      assert_patch(show_live, ~p"/tenant_agreements/#{tenant_agreement_live}/show/edit")

      assert show_live
             |> form("#tenant_agreement_live-form", tenant_agreement_live: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#tenant_agreement_live-form", tenant_agreement_live: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/tenant_agreements/#{tenant_agreement_live}")

      html = render(show_live)
      assert html =~ "Tenant agreement live updated successfully"
    end
  end
end
