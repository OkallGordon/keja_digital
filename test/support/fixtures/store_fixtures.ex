defmodule KejaDigital.StoreFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KejaDigital.Store` context.
  """

  alias KejaDigital.Repo
  alias KejaDigital.Store.DoorNumber

  def unique_user_email, do: "user#{System.unique_integer([:positive])}@gmail.com"  # Changed to gmail.com
  def valid_user_password, do: "hello world!"

  def create_door_number(number) do
    %DoorNumber{}
    |> DoorNumber.changeset(%{number: "A-#{number}", occupied: false})  # Changed format to A-123
    |> Repo.insert!()
  end

  def valid_user_attributes(attrs \\ %{}) do
    # Create a new unoccupied door number for this test
    unique_number = System.unique_integer([:positive])
    door_number = create_door_number(unique_number)

    base_attrs = %{
      email: unique_user_email(),
      password: valid_user_password(),
      door_number: door_number.number,
      confirmed_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      # Updated full_name to match format requirement (2-3 capitalized names)
      full_name: "John James Smith",
      postal_address: "123 Test St",
      # Updated to match Safaricom format exactly (07XX)
      phone_number: "0722345678",  # Safaricom format without +254
      nationality: "Kenyan",
      organization: "Test Org",
      next_of_kin: "Next Kin",
      # Updated next of kin contact to match Safaricom format
      next_of_kin_contact: "0722654321",
      passport: "ABC123456",
      role: "tenant"
    }

    Map.merge(attrs, base_attrs)
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> KejaDigital.Store.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
