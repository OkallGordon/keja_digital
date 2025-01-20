defmodule KejaDigital.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    field :subject, :string
    field :status, :string, default: "unread"
    field :sender_email, :string
    field :sender_name, :string
    field :recipient_id, :integer
    field :message_type, :string, default: "inquiry"
    field :read_at, :naive_datetime

    timestamps()
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :subject, :status, :sender_email, :sender_name,
                    :recipient_id, :message_type, :read_at])
    |> validate_required([:content, :sender_email, :sender_name])
    |> validate_format(:sender_email, ~r/^[^\s]+@[^\s]+$/)
    |> validate_inclusion(:status, ["read", "unread", "archived"])
    |> validate_inclusion(:message_type, ["inquiry", "support", "notification"])
  end
end
