defmodule KejaDigital.Properties do
  import Ecto.Query
  alias KejaDigital.Repo
  alias KejaDigital.Properties.Property
  alias Phoenix.PubSub

  def count_active_listings do
    Property
    |> where([p], p.status == "active")
    |> Repo.aggregate(:count, :id) || 0
  end

  def count_saved_properties do
    Property
    |> where([p], p.saved == true)
    |> Repo.aggregate(:count, :id) || 0
  end

  def list_properties(opts \\ []) do
    Property
    |> filter_by_status(opts[:status])
    |> filter_by_type(opts[:type])
    |> filter_by_owner(opts[:owner_id])
    |> filter_by_price_range(opts[:min_price], opts[:max_price])
    |> order_by_field(opts[:sort_by] || "inserted_at", opts[:sort_order] || "desc")
    |> limit(^(opts[:limit] || 100))
    |> Repo.all()
  end

  def create_property(attrs) do
    result = %Property{}
    |> Property.changeset(attrs)
    |> Repo.insert()

    case result do
      {:ok, property} ->
        broadcast_property_created(property)
        {:ok, property}
      error -> error
    end
  end

  def update_property(property, attrs) do
    result = property
    |> Property.changeset(attrs)
    |> Repo.update()

    case result do
      {:ok, updated_property} ->
        broadcast_property_updated(updated_property)
        {:ok, updated_property}
      error -> error
    end
  end

  def toggle_saved(property_id) do
    property = Repo.get!(Property, property_id)
    update_property(property, %{saved: !property.saved})
  end

  defp filter_by_status(query, nil), do: query
  defp filter_by_status(query, status) do
    where(query, [p], p.status == ^status)
  end

  defp filter_by_type(query, nil), do: query
  defp filter_by_type(query, type) do
    where(query, [p], p.property_type == ^type)
  end

  defp filter_by_owner(query, nil), do: query
  defp filter_by_owner(query, owner_id) do
    where(query, [p], p.owner_id == ^owner_id)
  end

  defp filter_by_price_range(query, nil, nil), do: query
  defp filter_by_price_range(query, min_price, nil) do
    where(query, [p], p.price >= ^min_price)
  end
  defp filter_by_price_range(query, nil, max_price) do
    where(query, [p], p.price <= ^max_price)
  end
  defp filter_by_price_range(query, min_price, max_price) do
    where(query, [p], p.price >= ^min_price and p.price <= ^max_price)
  end

  defp order_by_field(query, field, order) do
    order_by(query, [{^String.to_atom(order), ^String.to_atom(field)}])
  end

  defp broadcast_property_created(property) do
    PubSub.broadcast(KejaDigital.PubSub, "system_stats", :stats_updated)
    PubSub.broadcast(KejaDigital.PubSub, "properties", {:property_created, property})
  end

  defp broadcast_property_updated(property) do
    PubSub.broadcast(KejaDigital.PubSub, "system_stats", :stats_updated)
    PubSub.broadcast(KejaDigital.PubSub, "properties", {:property_updated, property})
  end
end
