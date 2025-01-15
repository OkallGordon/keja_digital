defmodule KejaDigitalWeb.UserProfileLive do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Store

  def mount(_params, session, socket) do
    user_token = session["user_token"]

    case Store.get_user_by_session_token(user_token) do
      nil ->
        {:error, redirect(socket, to: "/log_in")}

      user ->
        {:ok, assign(socket, current_user: user)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-6">
      <div class="bg-white shadow-lg rounded-lg overflow-hidden">
        <!-- Profile Header -->
        <div class="profile-header bg-gradient-to-r from-blue-600 to-blue-800 text-white p-8 relative">
          <div class="flex items-center space-x-6">
            <div class="profile-photo-container">
              <!-- Profile Photo -->
           <%= if @current_user.photo do %>
            <img
              src={"/uploads/users/photos/#{@current_user.id}/photo.jpg"}
              alt="Profile Photo"
              class="w-32 h-32 rounded-full border-4 border-blue-500 object-cover"
            />
          <% else %>
            <div class="w-32 h-32 rounded-full bg-gray-300 flex items-center justify-center text-gray-700 text-xl font-semibold">
              No Photo
            </div>
          <% end %>
            </div>
            <div>
              <h2 class="text-3xl font-bold mb-2"><%= @current_user.full_name %></h2>
              <p class="text-blue-100"><%= @current_user.role %></p>
            </div>
          </div>
        </div>

        <!-- Profile Details -->
        <div class="p-6">
          <div class="grid md:grid-cols-2 gap-6">
            <!-- Personal Information Section -->
            <div class="space-y-6">
              <h2 class="text-xl font-semibold text-gray-800 border-b pb-2">Personal Information</h2>
              <div class="profile-field">
                <span class="field-label">Email</span>
                <span class="field-value"><%= @current_user.email %></span>
              </div>
              <div class="profile-field">
                <span class="field-label">Phone Number</span>
                <span class="field-value"><%= @current_user.phone_number %></span>
              </div>
              <div class="profile-field">
                <span class="field-label">Nationality</span>
                <span class="field-value"><%= @current_user.nationality %></span>
              </div>
              <div class="profile-field">
                <span class="field-label">ID Number</span>
                <span class="field-value"><%= @current_user.passport %></span>
              </div>
            </div>

            <!-- Address Information Section -->
            <div class="space-y-6">
              <h3 class="text-xl font-semibold text-gray-800 border-b pb-2">Address Information</h3>
              <div class="profile-field">
                <span class="field-label">Door Number</span>
                <span class="field-value"><%= @current_user.door_number %></span>
              </div>
              <div class="profile-field">
                <span class="field-label">Organization</span>
                <span class="field-value"><%= @current_user.organization %></span>
              </div>
              <div class="profile-field">
                <span class="field-label">Postal Address</span>
                <span class="field-value"><%= @current_user.postal_address %></span>
              </div>
            </div>

            <!-- Emergency Contact Section -->
            <div class="space-y-6 md:col-span-2">
              <h3 class="text-xl font-semibold text-gray-800 border-b pb-2">Emergency Contact</h3>
              <div class="grid md:grid-cols-2 gap-6">
                <div class="profile-field">
                  <span class="field-label">Next of Kin</span>
                  <span class="field-value"><%= @current_user.next_of_kin %></span>
                </div>
                <div class="profile-field">
                  <span class="field-label">Next of Kin Contact</span>
                  <span class="field-value"><%= @current_user.next_of_kin_contact %></span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
