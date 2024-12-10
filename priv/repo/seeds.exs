# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     KejaDigital.Repo.insert!(%KejaDigital.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias KejaDigital.Backoffice

defmodule AdminSeeder do
  def seed_admins do
    admins = [
      %{
        email: "gordonochieng5454@gmail.com",
        password: "Obwandasupermaket@2000"
      },
      %{
        email: "okothkongo@gmail.com",
        password: "Semekombewa@2000"
      }
    ]

    Enum.each(admins, fn admin ->
      case Backoffice.get_admin_by_email(admin.email) do
        nil ->
          case Backoffice.register_admin(admin) do
            {:ok, _admin} ->
              IO.puts("Admin seeded: #{admin.email}")

            {:error, changeset} ->
              IO.puts("Failed to seed admin: #{admin.email}")
              IO.inspect(changeset.errors)
          end

        _existing_admin ->
          IO.puts("Admin already exists: #{admin.email}")
      end
    end)
  end
end

AdminSeeder.seed_admins()


alias KejaDigital.Repo
alias KejaDigital.Store.DoorNumber

# Ensure the DoorNumber schema and changeset are correctly loaded
IO.puts("Seeding door numbers...")

# List of door numbers to be seeded
door_numbers = [
  %{number: "Door 01", occupied: false},
  %{number: "Door 02", occupied: false},
  %{number: "Door 03", occupied: false},
  %{number: "Door 04", occupied: false},
  %{number: "Door 05", occupied: false},
  %{number: "Door 06", occupied: false},
  %{number: "Door 07", occupied: false},
  %{number: "Door 08", occupied: false},
  %{number: "Door 09", occupied: false},
  %{number: "Door 10", occupied: false}
]

# Iterate through each door number and insert it into the database if it doesn't exist
Enum.each(door_numbers, fn door_number ->
  case Repo.get_by(DoorNumber, number: door_number.number) do
    nil ->
      # Door number doesn't exist, insert it
      changeset = DoorNumber.changeset(%DoorNumber{}, door_number)

      case Repo.insert(changeset) do
        {:ok, _door_number} ->
          IO.puts("Door number seeded: #{door_number.number}")

        {:error, changeset} ->
          IO.puts("Failed to seed door number: #{door_number.number}")
          IO.inspect(changeset.errors)
      end

    _existing_door_number ->
      IO.puts("Door number already exists: #{door_number.number}")
  end
end)

IO.puts("Seeding completed!")
