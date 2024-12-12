defmodule KejaDigitalWeb.UserProfileLive do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Store

  def mount(_params, session, socket) do
    # Fetch user token from session
    user_token = session["user_token"]

    # Get the user based on the session token
    case Store.get_user_by_session_token(user_token) do
      nil ->
        {:error, redirect(socket, to: "/log_in")}  # Redirect if user is not found

      user ->
        # Assign user data to socket
        {:ok, assign(socket, current_user: user)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="profile-container">
      <div class="profile-header">
        <%= if @current_user.photo do %>
          <img
            src={"/uploads/users/photos/#{@current_user.id}/photo.jpg"}
            alt="Profile Photo"
            class="profile-photo"
          />
        <% else %>
          <div class="profile-photo-placeholder">No Photo</div>
        <% end %>
        <h2 class="profile-name"><%= @current_user.full_name %></h2>
      </div>

      <div class="profile-details">
        <div>
          <h3>Email</h3>
          <p><%= @current_user.email %></p>
        </div>
        <div>
          <h3>Role</h3>
          <p><%= @current_user.role %></p>
        </div>
        <div>
          <h3> Door Number</h3>
          <p><%= @current_user.door_number %></p>
        </div>
          <div>
          <h3>Organization</h3>
          <p><%= @current_user.organization %></p>
        </div>
        <div>
          <h3>Postal Address</h3>
          <p><%= @current_user.postal_address %></p>
        </div>
        <div>
          <h3>Phone Number</h3>
          <p><%= @current_user.phone_number %></p>
        </div>
        <div>
          <h3>Nationality</h3>
          <p><%= @current_user.nationality %></p>
        </div>
        <div>
          <h3>Identification Number</h3>
          <p><%= @current_user.passport %></p>
        </div>
        <div>
          <h3>Next of Kin</h3>
          <p><%= @current_user.next_of_kin %></p>
        </div>
        <div>
          <h3>Next of Kin Contact</h3>
          <p><%= @current_user.next_of_kin_contact %></p>
        </div>
      </div>
    </div>
    """
  end
end
