defmodule KejaDigitalWeb.BookingController do
  use KejaDigitalWeb, :controller
  alias KejaDigital.Repo
  alias KejaDigital.Store.DoorNumber

  def new(conn, %{"id" => door_id}) do
    case Repo.get(DoorNumber, door_id) do
      nil ->
        conn
        |> put_flash(:error, "Room not found")
        |> redirect(to: ~p"/properties/available/and_pricing")

      door ->
        if door.occupied do
          conn
          |> put_flash(:error, "This room is no longer available")
          |> redirect(to: ~p"/properties/available/and_pricing")
        else
          render(conn, :new, door: door)
        end
    end
  end

  def create(conn, %{"id" => door_id}) do
    user = conn.assigns.current_user

    case Repo.get(DoorNumber, door_id) do
      nil ->
        conn
        |> put_flash(:error, "Room not found")
        |> redirect(to: ~p"/properties/available/and_pricing")

      door ->
        if door.occupied do
          conn
          |> put_flash(:error, "This room is no longer available")
          |> redirect(to: ~p"/properties/available/and_pricing")
        else
          # Update door to be occupied and associate with user
          door
          |> DoorNumber.changeset(%{occupied: true, user_id: user.id})
          |> Repo.update()

          # Here you could also create a booking record
          # if you have a separate bookings table

          conn
          |> put_flash(:info, "Room #{door.number} has been booked successfully!")
          |> redirect(to: ~p"/messages")
        end
    end
  end
end
