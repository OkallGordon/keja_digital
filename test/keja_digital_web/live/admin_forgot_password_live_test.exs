defmodule KejaDigitalWeb.AdminForgotPasswordLiveTest do
  use KejaDigitalWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import KejaDigital.BackofficeFixtures

  alias KejaDigital.Backoffice
  alias KejaDigital.Repo

  describe "Forgot password page" do
    test "renders email page", %{conn: conn} do
      {:ok, lv, html} = live(conn, ~p"/admins/reset_password")

      assert html =~ "Forgot your password?"
      assert has_element?(lv, ~s|a[href="#{~p"/admins/register"}"]|, "Register")
      assert has_element?(lv, ~s|a[href="#{~p"/admins/log_in"}"]|, "Log in")
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_admin(admin_fixture())
        |> live(~p"/admins/reset_password")
        |> follow_redirect(conn, ~p"/")

      assert {:ok, _conn} = result
    end
  end

  describe "Reset link" do
    setup do
      %{admin: admin_fixture()}
    end

    test "sends a new reset password token", %{conn: conn, admin: admin} do
      {:ok, lv, _html} = live(conn, ~p"/admins/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", admin: %{"email" => admin.email})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"

      assert Repo.get_by!(Backoffice.AdminToken, admin_id: admin.id).context ==
               "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/admins/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", admin: %{"email" => "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"
      assert Repo.all(Backoffice.AdminToken) == []
    end
  end
end
