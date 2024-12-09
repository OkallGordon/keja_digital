defmodule KejaDigitalWeb.AdminSettingsLiveTest do
  use KejaDigitalWeb.ConnCase, async: true

  alias KejaDigital.Backoffice
  import Phoenix.LiveViewTest
  import KejaDigital.BackofficeFixtures

  describe "Settings page" do
    test "renders settings page", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> log_in_admin(admin_fixture())
        |> live(~p"/admins/settings")

      assert html =~ "Change Email"
      assert html =~ "Change Password"
    end

    test "redirects if admin is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/admins/settings")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/admins/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  describe "update email form" do
    setup %{conn: conn} do
      password = valid_admin_password()
      admin = admin_fixture(%{password: password})
      %{conn: log_in_admin(conn, admin), admin: admin, password: password}
    end

    test "updates the admin email", %{conn: conn, password: password, admin: admin} do
      new_email = unique_admin_email()

      {:ok, lv, _html} = live(conn, ~p"/admins/settings")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => password,
          "admin" => %{"email" => new_email}
        })
        |> render_submit()

      assert result =~ "A link to confirm your email"
      assert Backoffice.get_admin_by_email(admin.email)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/admins/settings")

      result =
        lv
        |> element("#email_form")
        |> render_change(%{
          "action" => "update_email",
          "current_password" => "invalid",
          "admin" => %{"email" => "with spaces"}
        })

      assert result =~ "Change Email"
      assert result =~ "must have the @ sign and no spaces"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn, admin: admin} do
      {:ok, lv, _html} = live(conn, ~p"/admins/settings")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => "invalid",
          "admin" => %{"email" => admin.email}
        })
        |> render_submit()

      assert result =~ "Change Email"
      assert result =~ "did not change"
      assert result =~ "is not valid"
    end
  end

  describe "update password form" do
    setup %{conn: conn} do
      password = valid_admin_password()
      admin = admin_fixture(%{password: password})
      %{conn: log_in_admin(conn, admin), admin: admin, password: password}
    end

    test "updates the admin password", %{conn: conn, admin: admin, password: password} do
      new_password = valid_admin_password()

      {:ok, lv, _html} = live(conn, ~p"/admins/settings")

      form =
        form(lv, "#password_form", %{
          "current_password" => password,
          "admin" => %{
            "email" => admin.email,
            "password" => new_password,
            "password_confirmation" => new_password
          }
        })

      render_submit(form)

      new_password_conn = follow_trigger_action(form, conn)

      assert redirected_to(new_password_conn) == ~p"/admins/settings"

      assert get_session(new_password_conn, :admin_token) != get_session(conn, :admin_token)

      assert Phoenix.Flash.get(new_password_conn.assigns.flash, :info) =~
               "Password updated successfully"

      assert Backoffice.get_admin_by_email_and_password(admin.email, new_password)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/admins/settings")

      result =
        lv
        |> element("#password_form")
        |> render_change(%{
          "current_password" => "invalid",
          "admin" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/admins/settings")

      result =
        lv
        |> form("#password_form", %{
          "current_password" => "invalid",
          "admin" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })
        |> render_submit()

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
      assert result =~ "is not valid"
    end
  end

  describe "confirm email" do
    setup %{conn: conn} do
      admin = admin_fixture()
      email = unique_admin_email()

      token =
        extract_admin_token(fn url ->
          Backoffice.deliver_admin_update_email_instructions(%{admin | email: email}, admin.email, url)
        end)

      %{conn: log_in_admin(conn, admin), token: token, email: email, admin: admin}
    end

    test "updates the admin email once", %{conn: conn, admin: admin, token: token, email: email} do
      {:error, redirect} = live(conn, ~p"/admins/settings/confirm_email/#{token}")

      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/admins/settings"
      assert %{"info" => message} = flash
      assert message == "Email changed successfully."
      refute Backoffice.get_admin_by_email(admin.email)
      assert Backoffice.get_admin_by_email(email)

      # use confirm token again
      {:error, redirect} = live(conn, ~p"/admins/settings/confirm_email/#{token}")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/admins/settings"
      assert %{"error" => message} = flash
      assert message == "Email change link is invalid or it has expired."
    end

    test "does not update email with invalid token", %{conn: conn, admin: admin} do
      {:error, redirect} = live(conn, ~p"/admins/settings/confirm_email/oops")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/admins/settings"
      assert %{"error" => message} = flash
      assert message == "Email change link is invalid or it has expired."
      assert Backoffice.get_admin_by_email(admin.email)
    end

    test "redirects if admin is not logged in", %{token: token} do
      conn = build_conn()
      {:error, redirect} = live(conn, ~p"/admins/settings/confirm_email/#{token}")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/admins/log_in"
      assert %{"error" => message} = flash
      assert message == "You must log in to access this page."
    end
  end
end
