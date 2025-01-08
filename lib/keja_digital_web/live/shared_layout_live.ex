defmodule KejaDigitalWeb.SharedLayoutLive do
  use KejaDigitalWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:nav_items, nav_items(socket.assigns.current_user))}
  end

  defp nav_items(%{role: :tenant} = _user) do
    [
      %{label: "Dashboard", icon: "home", path: ~p"/"},
      %{label: "Payments", icon: "credit-card", path: ~p"/payments"},
      %{label: "Profile", icon: "user", path: ~p"/tenant/profile"}
    ]
  end

  defp nav_items(%{role: :admin} = _user) do
    [
      %{label: "Dashboard", icon: "home", path: ~p"/dashboard"},
      %{label: "Tenants", icon: "users", path: ~p"/tenant/profile"},
      %{label: "Audit Logs", icon: "list", path: ~p"/dashboard"}
    ]
  end
end
