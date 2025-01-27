defmodule KejaDigital.StoreFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KejaDigital.Store` context.
  """

  def unique_user_email, do: "user#{System.unique_integer([:positive])}@example.com"
  def valid_user_password, do: "hello world!"

  def generate_unique_door_number do
    # Using a format like "A-123" for door numbers
    prefix = Enum.random(["A", "B", "C", "D"])
    number = System.unique_integer([:positive])
    "#{prefix}-#{number}"
  end

  def valid_user_attributes(attrs \\ %{}) do
    base_attrs = %{
      email: unique_user_email(),
      password: valid_user_password(),
      door_number: generate_unique_door_number(),
      confirmed_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }

    Map.merge(base_attrs, attrs)
  end

  def user_fixture(attrs \\ %{}) do
    try_create_user(attrs, 3)
  end

  defp try_create_user(_attrs, 0) do
    raise "Failed to create user after multiple attempts - door numbers already taken"
  end

  defp try_create_user(attrs, attempts) do
    case attrs
         |> valid_user_attributes()
         |> KejaDigital.Store.register_user() do
      {:ok, user} -> user
      {:error, :door_number_taken} -> try_create_user(attrs, attempts - 1)
      {:error, other_reason} = error ->
        raise "Failed to create user: #{inspect(error)}, reason: #{inspect(other_reason)}"
    end
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
