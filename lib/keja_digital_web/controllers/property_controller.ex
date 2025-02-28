defmodule KejaDigitalWeb.PropertyController do
  use KejaDigitalWeb, :controller
  alias KejaDigital.Repo
  alias KejaDigital.Store.DoorNumber
  import Ecto.Query

  def available(conn, _params) do
    # Fetch only unoccupied door numbers
    available_doors = DoorNumber
      |> where([d], d.occupied == false)
      |> order_by([d], d.number)
      |> Repo.all()

    # For pricing, we're using static data for now
    # but you could replace this with database data
    pricing_data = [
      %{room_type: "Standard Room", location: "Manyatta B, Kisumu", price: 4500}
    ]

    render(conn, :available, layout: false,
      available_doors: available_doors,
      pricing_data: pricing_data
    )
  end
end
