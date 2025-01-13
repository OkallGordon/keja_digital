defmodule KejaDigitalWeb.TenantShow do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Agreements

  def mount(%{"id" => _id}, _session, socket) do
    case socket.assigns[:current_user] do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "You must be logged in to view agreements")
         |> push_navigate(to: ~p"/users/log_in")}

      current_user ->
        case Agreements.get_tenant_agreement_by_user(current_user.id) do
          nil ->
            {:ok,
             socket
             |> put_flash(:error, "No agreement found")
             |> push_navigate(to: ~p"/tenant/dashboard")}

          tenant_agreement ->
            if tenant_agreement.tenant_id == current_user.id do
              {:ok, assign(socket, :tenant_agreement, tenant_agreement)}
            else
              {:ok,
               socket
               |> put_flash(:error, "You are not authorized to view this agreement")
               |> push_navigate(to: ~p"/tenant/dashboard")}
            end
        end
      end
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

        <div class="bg-white-100">
        <h2 class="text-xl font-semibold mt-6 mb-4">Agreement Content</h2>
          <p>
            This Tenancy Agreement is made and entered into between Pollet Obuya ("Landlord") and
            <u><strong><%= @tenant_agreement.tenant_name || "________________" %></strong></u> ("Tenant") and outlines the terms and conditions governing the rental of the premises by the Tenant from the Landlord.
          </p>
          <br>

          <h3><strong>1. Landlord/Landlady Information</strong></h3>
          <p><strong>Name:</strong> Pollet Obuya</p>
          <p><strong>Name:</strong> Evance Okoth</p>
          <p><strong>Phone Numbers:</strong> 0718584038, 0718077572 </p>
          <p><strong>Email:</strong> okothkongo@gmail.com </p>
          <p><strong>Location:</strong> 2738 Kisumu, Kenya </p>
          <p><strong>Property Description:</strong> Bedsitter Houses </p>
          <p><strong>Property Number:</strong> 2738 Kisumu, Kenya </p>
          <br>
          <h3><strong>2. Tenant Information</strong></h3>

          <div>
            <strong>Tenant Name:</strong> <%= @tenant_agreement.tenant_name %>
          </div>
          <div>
            <strong>Address:</strong> <%= @tenant_agreement.tenant_address %>
          </div>
          <div>
            <strong>Phone:</strong> <%= @tenant_agreement.tenant_phone %>
          </div>
          <br>
          <h3><strong>4. Rent</strong></h3>
          <br>
          <p>
            The tenant shall pay the landlord a rent of Kenya Shilling <strong><%= @tenant_agreement.rent %></strong> per month in advance. Payments shall be made via <strong>MPESA TILL NUMBER 4154742.</strong>
          </p>
          <br>
          <h3><strong>5. Security Deposit</strong></h3>
          <p>
            <strong>Deposit Amount:</strong> <%= @tenant_agreement.deposit %>
          </p>
          <br>
          <h3><strong>6. Occupancy</strong></h3>
          <p>The property is designated for 'single person' and student occupancy only.</p>
          <br>
          <h3><strong>7. Maintenance and Cleanliness</strong></h3>
          <p>The Tenant is responsible for keeping the premises in a clean and sanitary condition.</p>
          <br>
          <h3><strong>8. Morals</strong></h3>
          <p>The Tenant agrees to conduct themselves in a respectful manner and adhere to the terms of occupancy.</p>
          <br>
          <h3><strong>9. Inspections</strong></h3>
          <p>
            The caretaker reserves the right to inspect the property quarterly with 24 hours' notice.
          </p>
          <br>
          <h3><strong>10. Unauthorized Structures</strong></h3>
          <p>The Tenant is not permitted to make alterations or additions to the property without approval.</p>
          <br>
          <h3><strong>11. Termination of Tenancy</strong></h3>
          <p>
            If rent becomes more than 14 days in arrears, the Landlady retains the right to terminate the tenancy.
          </p>
          <br>
          <h3><strong>12. In Witness of Parties</strong></h3>
          <p>This agreement is acknowledged by the Caretaker.</p>
          <br>
          <h3><strong>13. Tenant Acknowledgment</strong></h3>
          <p>
            By signing this agreement, the Tenant acknowledges understanding and agreeing to the terms.
          </p>
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
