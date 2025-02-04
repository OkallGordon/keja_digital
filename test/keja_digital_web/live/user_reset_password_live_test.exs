defmodule KejaDigitalWeb.UserResetPasswordLiveTest do
  use KejaDigitalWeb.ConnCase

  import Phoenix.LiveViewTest
  import KejaDigital.StoreFixtures

  alias KejaDigital.Store

  setup do
    user = user_fixture()
    token = extract_user_token(fn url -> Store.deliver_user_reset_password_instructions(user, url) end)
    %{token: token, user: user}
  end

  test "renders reset password page", %{conn: conn, token: token} do
    {:ok, _lv, html} = live(conn, ~p"/users/reset_password/#{token}")
    assert html =~ "Reset Password"
  end

  test "does not render reset password with invalid token", %{conn: conn} do
    {:error, {:redirect, to}} = live(conn, ~p"/users/reset_password/invalid")
    assert to == %{
      flash: %{"error" => "Reset password link is invalid or it has expired."},
      to: ~p"/"
    }
  end

  test "resets password once", %{conn: conn, token: token, user: user} do
    {:ok, lv, _html} = live(conn, ~p"/users/reset_password/#{token}")

    {:ok, conn} =
      lv
      |> form("#reset_password_form",
        user: %{
          "password" => "new valid password",
          "password_confirmation" => "new valid password"
        }
      )
      |> render_submit()
      |> follow_redirect(conn, ~p"/users/log_in")

    assert conn.resp_body =~ "Password reset successfully"
    refute get_session(conn, :user_token)
    assert Store.get_user_by_email_and_password(user.email, "new valid password")
  end

  test "does not reset password with invalid token", %{conn: conn} do
    {:ok, lv, _html} = live(conn, ~p"/users/reset_password/invalid")

    {:ok, conn} =
      lv
      |> form("#reset_password_form",
        user: %{
          "password" => "new valid password",
          "password_confirmation" => "new valid password"
        }
      )
      |> render_submit()
      |> follow_redirect(conn, ~p"/")

    assert conn.resp_body =~ "Reset password link is invalid or it has expired"
  end

  test "does not reset password with mismatched passwords", %{conn: conn, token: token} do
    {:ok, lv, _html} = live(conn, ~p"/users/reset_password/#{token}")

    result =
      lv
      |> form("#reset_password_form",
        user: %{
          "password" => "valid password",
          "password_confirmation" => "different"
        }
      )
      |> render_submit()

    assert result =~ "should be the same as the password"
  end

  test "does not reset password with too short password", %{conn: conn, token: token} do
    {:ok, lv, _html} = live(conn, ~p"/users/reset_password/#{token}")

    result =
      lv
      |> form("#reset_password_form",
        user: %{
          "password" => "123",
          "password_confirmation" => "123"
        }
      )
      |> render_submit()

    assert result =~ "should be at least 12 character"
  end
end
