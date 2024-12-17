defmodule KejaDigital.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :title, :string
    field :content, :string
    field :is_read, :boolean, default: false
    field :user_id, :id
    field :tenant_agreement_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:title, :content, :is_read])
    |> validate_required([:title, :content, :is_read])
  end
end
