defmodule KejaDigitalWeb.UserRegistrationLiveTest do
  use KejaDigitalWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import KejaDigital.StoreFixtures

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/register")

      assert html =~ "Register"
      assert html =~ "Log in"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/register")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(user: %{"email" => "with spaces", "password" => "too short"})

      assert result =~ "Register"
      assert result =~ "must have the @ sign and no spaces"
      assert result =~ "should be at least 12 character"
    end
  end

  test "creates account and logs the user in", %{conn: conn} do
    # Create door number before loading the LiveView
    door = create_door_number(123)

    {:ok, lv, _html} = live(conn, ~p"/users/register")

    Process.sleep(100)
    rendered_content = render(lv)
    assert rendered_content =~ door.number

    # Prepare user attributes
    email = unique_user_email()

    attrs = %{
      email: email,
      password: valid_user_password(),
      door_number: door.number,
      full_name: "John James Smith",
      postal_address: "123 Test St",
      phone_number: "0722345678",
      nationality: "Kenyan",
      organization: "Test Org",
      next_of_kin: "Next Kin",
      next_of_kin_contact: "0722654321",
      passport: "ABC123456"
    }

    form = form(lv, "#registration_form", user: attrs)
    render_submit(form)
    conn = follow_trigger_action(form, conn)

    assert redirected_to(conn) == ~p"/"

    conn = get(conn, "/")
    response = html_response(conn, 200)
    assert response =~ email
    assert response =~ "Settings"
    assert response =~ "Log out"
  end

  test "renders errors for duplicated email", %{conn: conn} do
    door = create_door_number(124)

    user = user_fixture(%{email: "test@email.com"})

    {:ok, lv, _html} = live(conn, ~p"/users/register")

    Process.sleep(100)
    rendered_content = render(lv)
    assert rendered_content =~ door.number

    result =
      lv
      |> form("#registration_form",
        user: %{
          "email" => user.email,
          "password" => "valid_password",
          "full_name" => "John James Smith",
          "phone_number" => "0722345678",
          "nationality" => "Kenyan",
          "postal_address" => "123 Test St",
          "organization" => "Test Org",
          "passport" => "ABC123456",
          "door_number" => door.number,
          "next_of_kin" => "Next Kin",
          "next_of_kin_contact" => "0722654321"
        }
      )
      |> render_submit()

    assert result =~ "has already been taken"
  end

  describe "registration navigation" do
    test "redirects to login page when the Log in button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s|main a:fl-contains("Log in")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/users/log_in")

      assert login_html =~ "Log in"
    end
  end
end
