defmodule KejaDigital.Messages do
  import Ecto.Query
  alias KejaDigital.Repo
  alias KejaDigital.Messages.Message
  alias Phoenix.PubSub

  def count_total_messages do
    Repo.aggregate(Message, :count, :id) || 0
  end

  def count_unread_messages do
    Message
    |> where([m], m.status == "unread")
    |> Repo.aggregate(:count, :id) || 0
  end

  def list_messages(opts \\ []) do
    Message
    |> filter_by_status(opts[:status])
    |> filter_by_type(opts[:type])
    |> filter_by_recipient(opts[:recipient_id])
    |> order_by([m], desc: m.inserted_at)
    |> limit(^(opts[:limit] || 100))
    |> Repo.all()
  end

  def create_message(attrs) do
    result = %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()

    case result do
      {:ok, message} ->
        broadcast_message_created(message)
        {:ok, message}
      error -> error
    end
  end

  def mark_as_read(message_id) do
    message = Repo.get!(Message, message_id)

    result = message
    |> Message.changeset(%{status: "read", read_at: NaiveDateTime.utc_now()})
    |> Repo.update()

    case result do
      {:ok, updated_message} ->
        broadcast_message_updated(updated_message)
        {:ok, updated_message}
      error -> error
    end
  end

  defp filter_by_status(query, nil), do: query
  defp filter_by_status(query, status) do
    where(query, [m], m.status == ^status)
  end

  defp filter_by_type(query, nil), do: query
  defp filter_by_type(query, type) do
    where(query, [m], m.message_type == ^type)
  end

  defp filter_by_recipient(query, nil), do: query
  defp filter_by_recipient(query, recipient_id) do
    where(query, [m], m.recipient_id == ^recipient_id)
  end

  defp broadcast_message_created(message) do
    PubSub.broadcast(KejaDigital.PubSub, "system_stats", :stats_updated)
    PubSub.broadcast(KejaDigital.PubSub, "messages", {:message_created, message})
  end

  defp broadcast_message_updated(message) do
    PubSub.broadcast(KejaDigital.PubSub, "messages", {:message_updated, message})
  end
end
