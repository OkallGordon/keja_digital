defmodule KejaDigitalWeb.UserConfirmationLiveTest do
  use KejaDigitalWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import KejaDigital.StoreFixtures

  alias KejaDigital.Store
  #alias KejaDigital.Repo

  setup do
    %{user: user_fixture()}
  end

  describe "Confirm user" do
    test "renders confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/confirm/some-token")
      assert html =~ "Confirm Account"
    end

    test "confirms the given token once", %{conn: conn, user: user} do
      token =
        extract_user_token(fn url ->
          Store.deliver_user_confirmation_instructions(user, url)
        end)

      {:ok, lv, _html} = live(conn, ~p"/users/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      flash_message = Phoenix.Flash.get(conn.assigns.flash, :info)
      assert flash_message != nil
      assert flash_message =~ "User confirmed successfully"
    end

    test "does not confirm email with invalid token", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/users/confirm/invalid-token")

      {:ok, conn} =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      flash_message = Phoenix.Flash.get(conn.assigns.flash, :error)

      IO.inspect(flash_message, label: "Flash message on invalid token")

      assert flash_message != nil
      assert flash_message =~ "User confirmation link is invalid or it has expired"

      refute Store.get_user!(user.id).confirmed_at
    end
  end
end
