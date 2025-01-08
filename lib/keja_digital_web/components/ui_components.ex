defmodule KejaDigitalWeb.Components do
  use Phoenix.Component

  # A generic card component
  def card(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow duration-200">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # A stat card component with dynamic background and text colors
  def stat_card(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow p-4">
      <div class="flex items-center">
        <div class={"p-3 rounded-full #{@bg_color} bg-opacity-10"}>
          <%= render_icon(@icon, @text_color) %>
        </div>
        <div class="ml-4">
          <h4 class="text-gray-500 font-medium"><%= @title %></h4>
          <p class="text-2xl font-bold"><%= @value %></p>
        </div>
      </div>
    </div>
    """
  end

  # A mobile navigation bar component
  def mobile_nav(assigns) do
    ~H"""
    <div class="lg:hidden">
      <div class="fixed bottom-0 left-0 right-0 bg-white border-t px-4 pb-safe-area-inset-bottom">
        <div class="flex justify-around py-2">
          <%= for item <- @nav_items do %>
            <.link navigate={item.path} class="flex flex-col items-center">
              <%= render_icon(item.icon) %>
              <span class="text-xs mt-1"><%= item.label %></span>
            </.link>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  # Function to render a Heroicon SVG icon
  defp render_icon(icon_name, text_color \\ "text-gray-700") do
    assigns = %{text_color: text_color}
    case icon_name do
      :heart ->
        ~H"""
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class={"w-6 h-6 #{@text_color}"}>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7 7 7-7"></path>
        </svg>
        """
      :user ->
        ~H"""
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class={"w-6 h-6 #{@text_color}"}>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3a7 7 0 0114 0v4a7 7 0 01-14 0V3z"></path>
        </svg>
        """
      # Add more icons as needed
      _ ->
        ~H"""
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class={"w-6 h-6 #{@text_color}"}>
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
        </svg>
        """
    end
  end
end
