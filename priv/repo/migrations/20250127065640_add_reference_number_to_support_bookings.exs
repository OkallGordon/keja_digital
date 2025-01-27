defmodule KejaDigital.Repo.Migrations.AddReferenceNumberToSupportBookings do
  use Ecto.Migration

  def change do
    alter table(:support_bookings) do
      add :reference_number, :string
    end

    create unique_index(:support_bookings, [:reference_number])
  end
end
