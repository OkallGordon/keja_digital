defmodule KejaDigitalWeb.AgreementStatusLive do
  use KejaDigitalWeb, :live_view
  alias Phoenix.PubSub

  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(KejaDigital.PubSub, "admin_notifications")
    end

    tenant_agreements = KejaDigital.Agreements.list_pending_tenant_agreements()
    {:ok, assign(socket, :tenant_agreements, tenant_agreements)}
  end

  def handle_info({:new_tenant_agreement, tenant_agreement}, socket) do
    {:noreply,
     update(socket, :tenant_agreements, fn agreements ->
       [tenant_agreement | agreements]
     end)}
  end

  def handle_info({:updated_tenant_agreement, updated_agreement}, socket) do
    {:noreply,
     update(socket, :tenant_agreements, fn agreements ->
       agreements
       |> Enum.map(fn agreement ->
         if agreement.id == updated_agreement.id, do: updated_agreement, else: agreement
       end)
       |> Enum.filter(&(&1.status == "pending_review"))
     end)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 py-8">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="bg-white rounded-lg shadow">
          <div class="px-6 py-4 border-b border-gray-200">
            <h2 class="text-2xl font-semibold text-gray-800">
              Tenant agreements pending reviews
            </h2>
          </div>

          <div class="divide-y divide-gray-200">
            <%= if Enum.empty?(@tenant_agreements) do %>
              <div class="px-6 py-12 text-center">
                <p class="text-gray-500 text-lg">
                  No pending agreements to review
                </p>
              </div>
            <% else %>
              <%= for agreement <- @tenant_agreements do %>
                <div class="px-6 py-6 flex items-center justify-between hover:bg-gray-50 transition-colors duration-150">
                  <div class="flex-1">
                    <div class="flex items-center">
                      <div class="flex-shrink-0">
                        <div class="h-12 w-12 rounded-full bg-indigo-100 flex items-center justify-center">
                          <svg class="h-6 w-6 text-indigo-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                          </svg>
                        </div>
                      </div>
                      <div class="ml-4">
                        <h3 class="text-lg font-medium text-gray-900">
                          <%= agreement.tenant_name %>
                        </h3>
                        <div class="mt-1 flex items-center space-x-4 text-sm text-gray-500">
                          <span>
                            Submitted <%= Calendar.strftime(agreement.inserted_at, "%B %d, %Y at %I:%M %p") %>
                          </span>
                          <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                            <%= String.replace(agreement.status, "_", " ") |> String.capitalize() %>
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="ml-6">
                    <.link
                      navigate={~p"/tenant_agreement/#{agreement.id}"}
                      class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-colors duration-150"
                    >
                      Review Agreement
                      <svg class="ml-2 -mr-1 h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                      </svg>
                    </.link>
                  </div>
                </div>
              <% end %>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
