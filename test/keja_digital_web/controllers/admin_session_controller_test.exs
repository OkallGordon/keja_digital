defmodule KejaDigitalWeb.AdminSessionControllerTest do
  use KejaDigitalWeb.ConnCase, async: true

  import KejaDigital.BackofficeFixtures

  setup do
    %{admin: admin_fixture()}
  end

  describe "POST /admins/log_in" do
    test "logs the admin in", %{conn: conn, admin: admin} do
      conn =
        post(conn, ~p"/admins/log_in", %{
          "admin" => %{"email" => admin.email, "password" => valid_admin_password()}
        })

      assert get_session(conn, :admin_token)
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ admin.email
      assert response =~ ~p"/admins/settings"
      assert response =~ ~p"/admins/log_out"
    end

    test "logs the admin in with remember me", %{conn: conn, admin: admin} do
      conn =
        post(conn, ~p"/admins/log_in", %{
          "admin" => %{
            "email" => admin.email,
            "password" => valid_admin_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_keja_digital_web_admin_remember_me"]
      assert redirected_to(conn) == ~p"/"
    end

    test "logs the admin in with return to", %{conn: conn, admin: admin} do
      conn =
        conn
        |> init_test_session(admin_return_to: "/foo/bar")
        |> post(~p"/admins/log_in", %{
          "admin" => %{
            "email" => admin.email,
            "password" => valid_admin_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "login following registration", %{conn: conn, admin: admin} do
      conn =
        conn
        |> post(~p"/admins/log_in", %{
          "_action" => "registered",
          "admin" => %{
            "email" => admin.email,
            "password" => valid_admin_password()
          }
        })

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Account created successfully"
    end

    test "login following password update", %{conn: conn, admin: admin} do
      conn =
        conn
        |> post(~p"/admins/log_in", %{
          "_action" => "password_updated",
          "admin" => %{
            "email" => admin.email,
            "password" => valid_admin_password()
          }
        })

      assert redirected_to(conn) == ~p"/admins/settings"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Password updated successfully"
    end

    test "redirects to login page with invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/admins/log_in", %{
          "admin" => %{"email" => "invalid@email.com", "password" => "invalid_password"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
      assert redirected_to(conn) == ~p"/admins/log_in"
    end
  end

  describe "DELETE /admins/log_out" do
    test "logs the admin out", %{conn: conn, admin: admin} do
      conn = conn |> log_in_admin(admin) |> delete(~p"/admins/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :admin_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the admin is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/admins/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :admin_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end
