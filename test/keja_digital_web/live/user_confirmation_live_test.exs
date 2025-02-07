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

    test "does not confirm email with invalid token", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/users/confirm/invalid-token")

      {:ok, conn} =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      flash_message = Phoenix.Flash.get(conn.assigns.flash, :error)

      assert flash_message != nil
      assert flash_message =~ "User confirmation link is invalid or it has expired"

      refute Store.get_user!(user.id).confirmed_at
    end
  end
end
