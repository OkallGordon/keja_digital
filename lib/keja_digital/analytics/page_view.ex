defmodule KejaDigital.Analytics.PageView do
  use Ecto.Schema
  import Ecto.Changeset

  schema "page_views" do
    field :path, :string
    field :view_count, :integer, default: 0
    field :viewed_on, :date
    field :ip_address, :string
    field :user_agent, :string
    field :referrer, :string
    field :viewer_id, :integer
    field :viewer_type, :string

    timestamps()
  end

  def changeset(page_view, attrs) do
    page_view
    |> cast(attrs, [:path, :view_count, :viewed_on, :ip_address, :user_agent, :referrer, :viewer_id, :viewer_type])
    |> validate_required([:path, :view_count, :viewed_on])
  end
end
