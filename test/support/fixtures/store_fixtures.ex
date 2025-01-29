defmodule KejaDigital.StoreFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KejaDigital.Store` context.
  """

  alias KejaDigital.Repo
  alias KejaDigital.Store.DoorNumber

  def unique_user_email, do: "user#{System.unique_integer([:positive])}@example.com"
  def valid_user_password, do: "hello world!"

  def create_door_number(number) do
    %DoorNumber{}
    |> DoorNumber.changeset(%{number: "Door #{number}", occupied: false})
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
      confirmed_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    Map.merge(base_attrs, attrs)
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
