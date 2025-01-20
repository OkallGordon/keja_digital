defmodule KejaDigital.Analytics do
  import Ecto.Query
  alias KejaDigital.Repo
  alias KejaDigital.Analytics.PageView
  alias Phoenix.PubSub

  def get_total_views do
    Repo.aggregate(PageView, :sum, :view_count) || 0
  end

  def get_views_by_date_range(start_date, end_date) do
    PageView
    |> where([pv], pv.viewed_on >= ^start_date and pv.viewed_on <= ^end_date)
    |> group_by([pv], [pv.viewed_on])
    |> select([pv], %{
      date: pv.viewed_on,
      total_views: sum(pv.view_count)
    })
    |> order_by([pv], asc: pv.viewed_on)
    |> Repo.all()
  end

  def track_view(page_path, tracking_info, user \\ nil) do
    today = Date.utc_today()
    attrs = Map.merge(tracking_info, %{
      path: page_path,
      view_count: 1,
      viewed_on: today,
      viewer_id: user && user.id,
      viewer_type: if(user, do: "user", else: "guest")
    })

    result = Repo.insert(
      %PageView{}
      |> PageView.changeset(attrs),
      on_conflict: [inc: [view_count: 1]],
      conflict_target: [:path, :viewed_on, :viewer_id]
    )

    broadcast_update()
    result
  end

  def get_popular_pages(limit \\ 10) do
    PageView
    |> group_by([pv], [pv.path])
    |> select([pv], %{
      path: pv.path,
      total_views: sum(pv.view_count)
    })
    |> order_by([pv], desc: sum(pv.view_count))
    |> limit(^limit)
    |> Repo.all()
  end

  def get_views_by_user(limit \\ 10) do
    PageView
    |> where([pv], not is_nil(pv.viewer_id))
    |> join(:left, [pv], u in "users", on: u.id == pv.viewer_id)
    |> group_by([pv, u], [u.id, u.email, u.full_name])
    |> select([pv, u], %{
      user_id: u.id,
      email: u.email,
      name: u.full_name,
      total_views: sum(pv.view_count),
      last_viewed: max(pv.viewed_on)
    })
    |> order_by([pv, u], [desc: sum(pv.view_count)])
    |> limit(^limit)
    |> Repo.all()
  end

  defp broadcast_update do
    PubSub.broadcast(KejaDigital.PubSub, "system_stats", :stats_updated)
  end
end
