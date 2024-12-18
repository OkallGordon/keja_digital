defmodule KejaDigitalWeb.AdminShow do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Agreements

  def mount(%{"id" => id}, _session, socket) do
    # Fetch the specific tenant agreement
    tenant_agreement = Agreements.get_tenant_agreement_live!(id)

    {:ok,
     socket
     |> assign(:tenant_agreement, tenant_agreement)}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-6">
      <h1 class="text-2xl font-bold mb-4">Tenant Agreement Details</h1>

      <div class="bg-white shadow-md rounded-lg p-6">
        <h2 class="text-xl font-semibold mb-4">Tenant Information</h2>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <strong>Name:</strong> <%= @tenant_agreement.tenant_name %>
          </div>
          <div>
            <strong>Address:</strong> <%= @tenant_agreement.tenant_address %>
          </div>
          <div>
            <strong>Phone:</strong> <%= @tenant_agreement.tenant_phone %>
          </div>
        </div>

        <h2 class="text-xl font-semibold mt-6 mb-4">Agreement Details</h2>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <strong>Rent:</strong> <%= @tenant_agreement.rent %>
          </div>
          <div>
            <strong>Deposit:</strong> <%= @tenant_agreement.deposit %>
          </div>
          <div>
            <strong>Start Date:</strong> <%= @tenant_agreement.start_date %>
          </div>
          <div>
            <strong>Status:</strong> <%= @tenant_agreement.status %>
          </div>
        </div>

        <h2 class="text-xl font-semibold mt-6 mb-4">Agreement Content</h2>
        <div class="bg-gray-100 p-4 rounded">
          <%= @tenant_agreement.agreement_content %>
        </div>

        <div class="mt-6 flex space-x-4">
          <button
            phx-click="approve"
            class="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600"
          >
            Approve
          </button>
          <button
            phx-click="reject"
            class="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600"
          >
            Reject
          </button>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("approve", _params, socket) do
    tenant_agreement = socket.assigns.tenant_agreement

    case Agreements.update_tenant_agreement_status(tenant_agreement.id, "approved") do
      {:ok, _updated_agreement} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tenant agreement approved")
         |> push_navigate(to: "/dashboard")}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to approve agreement")}
    end
  end

  def handle_event("reject", _params, socket) do
    tenant_agreement = socket.assigns.tenant_agreement

    case Agreements.update_tenant_agreement_status(tenant_agreement.id, "rejected") do
      {:ok, _updated_agreement} ->
        {:noreply,
         socket
         |> put_flash(:info, "Tenant agreement rejected")
         |> push_navigate(to: "/dashboard")}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to reject agreement")}
    end
  end
end
