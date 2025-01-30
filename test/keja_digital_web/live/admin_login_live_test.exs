defmodule KejaDigitalWeb.AdminLoginLiveTest do
  use KejaDigitalWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import KejaDigital.BackofficeFixtures

  describe "Log in page" do
    test "renders log in page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/admins/log_in")
      assert html =~ "Sign in"
      assert html =~ "Sign up"
      assert html =~ "Forgot your password?"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_admin(admin_fixture())
        |> live(~p"/admins/log_in")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end
  end

  describe "admin login" do
    test "redirects if admin login with valid credentials", %{conn: conn} do
      password = "123456789abcd"
      admin = admin_fixture(%{password: password})
      {:ok, lv, _html} = live(conn, ~p"/admins/log_in")

      form = form(lv, "#login_form", admin: %{email: admin.email, password: password, remember_me: true})
      conn = submit_form(form, conn)

      assert redirected_to(conn) == ~p"/"
    end

    test "redirects to login page with a flash error if there are no valid credentials", %{
      conn: conn
    } do
      {:ok, lv, _html} = live(conn, ~p"/admins/log_in")

      form =
        form(lv, "#login_form", admin: %{email: "test@email.com", password: "123456", remember_me: true})

      conn = submit_form(form, conn)

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
      assert redirected_to(conn) == "/admins/log_in"
    end
  end

  describe "login navigation" do
    test "redirects to registration page when the Register button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/admins/log_in")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s|main a:fl-contains("Sign up")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/admins/register")

      assert login_html =~ "Register"
    end

    test "redirects to forgot password page when the Forgot Password button is clicked", %{
      conn: conn
    } do
      {:ok, lv, _html} = live(conn, ~p"/admins/log_in")

      {:ok, conn} =
        lv
        |> element(~s|main a:fl-contains("Forgot your password?")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/admins/reset_password")

      assert conn.resp_body =~ "Forgot your password?"
    end
  end
end
