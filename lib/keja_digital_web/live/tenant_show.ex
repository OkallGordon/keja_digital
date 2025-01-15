defmodule KejaDigitalWeb.TenantShow do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Agreements

  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    tenant_name = current_user.full_name

    case Agreements.get_tenant_agreement_by_name(tenant_name) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "No agreement found")
         |> push_navigate(to: ~p"/tenant/dashboard")}

      tenant_agreement ->
        {:ok, assign(socket, :tenant_agreement, tenant_agreement)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 py-8">
      <div class="max-w-4xl mx-auto">
        <!-- Header Section -->
        <div class="bg-white shadow-lg rounded-lg mb-6 p-6">
          <div class="flex items-center justify-between">
            <div>
              <h1 class="text-3xl font-bold text-gray-900">Rental Agreement</h1>
              <p class="text-gray-600 mt-1">Agreement Reference: #<%= @tenant_agreement.id %></p>
            </div>

            </div>
          </div>
        </div>

        <!-- Main Content -->
        <div class="bg-white shadow-lg rounded-lg">
          <!-- Quick Summary -->
          <div class="border-b border-gray-200 p-6">
            <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
              <div class="flex flex-col">
                <span class="text-sm font-medium text-gray-500">Status</span>
                <span class={"px-3 py-1 rounded-full text-sm font-medium #{status_color(@tenant_agreement.status)}"}>
                  <%= String.capitalize(@tenant_agreement.status) %>
                </span>
              </div>
              <div class="flex flex-col">
                <span class="text-sm font-medium text-gray-500">Monthly Rent</span>
                <span class="text-lg font-semibold text-gray-900">KES <%= @tenant_agreement.rent %></span>
              </div>
              <div class="flex flex-col">
                <span class="text-sm font-medium text-gray-500">Deposit</span>
                <span class="text-lg font-semibold text-gray-900">KES <%= @tenant_agreement.deposit %></span>
              </div>
              <div class="flex flex-col">
                <span class="text-sm font-medium text-gray-500">Start Date</span>
                <span class="text-lg font-semibold text-gray-900"><%= @tenant_agreement.start_date %></span>
              </div>
            </div>
          </div>

          <!-- Agreement Content -->
          <div class="p-6 space-y-8">
            <!-- Tenant Information -->
            <div class="bg-gray-50 rounded-lg p-6">
              <h2 class="text-xl font-semibold text-gray-900 mb-4">Tenant Information</h2>
              <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div>
                  <span class="text-sm font-medium text-gray-500">Name</span>
                  <p class="mt-1 text-gray-900"><%= @tenant_agreement.tenant_name %></p>
                </div>
                <div>
                  <span class="text-sm font-medium text-gray-500">Address</span>
                  <p class="mt-1 text-gray-900"><%= @tenant_agreement.tenant_address %></p>
                </div>
                <div>
                  <span class="text-sm font-medium text-gray-500">Phone</span>
                  <p class="mt-1 text-gray-900"><%= @tenant_agreement.tenant_phone %></p>
                </div>
              </div>
            </div>

            <!-- Landlord Information -->
            <div class="bg-gray-50 rounded-lg p-6">
              <h2 class="text-xl font-semibold text-gray-900 mb-4">Landlord Information</h2>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <span class="text-sm font-medium text-gray-500">Names</span>
                  <p class="mt-1 text-gray-900">Pollet Obuya</p>
                  <p class="text-gray-900">Evance Okoth</p>
                </div>
                <div>
                  <span class="text-sm font-medium text-gray-500">Contact</span>
                  <p class="mt-1 text-gray-900">Phone: 0718584038, 0718077572</p>
                  <p class="text-gray-900">Email: okothkongo@gmail.com</p>
                </div>
              </div>
            </div>

            <!-- Agreement Terms -->
            <div class="space-y-6">
              <h2 class="text-2xl font-bold text-gray-900">Agreement Terms</h2>

              <div class="prose max-w-none">
                <h3 class="text-lg font-semibold text-gray-900">4. Rent</h3>
                <p class="text-gray-700">
                  The tenant shall pay the landlord a rent of Kenya Shilling <strong><%= @tenant_agreement.rent %></strong>
                  per month in advance. Payments shall be made via <strong>MPESA TILL NUMBER 4154742.</strong>
                </p>

                <h3 class="text-lg font-semibold text-gray-900 mt-6">5. Security Deposit</h3>
                <p class="text-gray-700">
                  <strong>Deposit Amount:</strong> <%= @tenant_agreement.deposit %>
                </p>

                <h3 class="text-lg font-semibold text-gray-900 mt-6">6. Occupancy</h3>
                <p class="text-gray-700">The property is designated for 'single person' and student occupancy only.</p>

                <h3 class="text-lg font-semibold text-gray-900 mt-6">7. Maintenance and Cleanliness</h3>
                <p class="text-gray-700">The Tenant is responsible for keeping the premises in a clean and sanitary condition.</p>

                <h3 class="text-lg font-semibold text-gray-900 mt-6">8. Morals</h3>
                <p class="text-gray-700">The Tenant agrees to conduct themselves in a respectful manner and adhere to the terms of occupancy.</p>

                <h3 class="text-lg font-semibold text-gray-900 mt-6">9. Inspections</h3>
                <p class="text-gray-700">The caretaker reserves the right to inspect the property quarterly with 24 hours' notice.</p>

                <h3 class="text-lg font-semibold text-gray-900 mt-6">10. Unauthorized Structures</h3>
                <p class="text-gray-700">The Tenant is not permitted to make alterations or additions to the property without approval.</p>

                <h3 class="text-lg font-semibold text-gray-900 mt-6">11. Termination of Tenancy</h3>
                <p class="text-gray-700">If rent becomes more than 14 days in arrears, the Landlady retains the right to terminate the tenancy.</p>
              </div>

              <!-- Signature Section -->
              <div class="mt-8 pt-8 border-t border-gray-200">
                <h3 class="text-lg font-semibold text-gray-900">Agreement Acknowledgment</h3>
                <p class="mt-2 text-gray-700">
                  By signing this agreement, both parties acknowledge understanding and agreeing to the terms stated above.
                </p>
              </div>
            </div>
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

  # Helper function for status color
  defp status_color(status) do
    case status do
      "approved" -> "bg-green-100 text-green-800"
      "rejected" -> "bg-red-100 text-red-800"
      _ -> "bg-yellow-100 text-yellow-800"
    end
  end
end
