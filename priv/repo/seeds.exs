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
