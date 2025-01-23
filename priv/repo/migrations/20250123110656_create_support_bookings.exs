defmodule KejaDigital.Repo.Migrations.CreateSupportBookings do
  use Ecto.Migration

  def change do
    create table(:support_bookings) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :email, :string, null: false
      add :phone, :string, null: false
      add :booking_type, :string, null: false
      add :description, :text
      add :preferred_date, :date
      add :status, :string, default: "pending"

      timestamps()
    end

    create index(:support_bookings, [:email])
    create index(:support_bookings, [:booking_type])
    create index(:support_bookings, [:preferred_date])
end
end
