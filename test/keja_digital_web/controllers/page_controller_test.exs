defmodule KejaDigitalWeb.PageControllerTest do
  use KejaDigitalWeb.ConnCase

  test "GET / renders the home page with correct content", %{conn: conn} do
    conn = get(conn, "/")
    response = html_response(conn, 200)

    # Check page title elements
    assert response =~ "Find Your Perfect Room in Kisumu"
    assert response =~ "Discover spacious, comfortable rooms in Manyatta B"

    # Check feature section
    assert response =~ "Why Choose Pollet's and Okoth Rentals?"
    assert response =~ "Clean & Spacious"
    assert response =~ "Modern Amenities"
    assert response =~ "Tight Security"

    # Check available rooms section
    assert response =~ "Available Rooms"
    assert response =~ "Spacious Room - Manyatta B"
    assert response =~ "KSH 4,500"
    assert response =~ "View Details"

    # Check call to action section
    assert response =~ "Looking for a Comfortable Room in Kisumu?"
    assert response =~ "Pollet's and Okoth Rentals - Your Home Away from Home"
    assert response =~ "Contact Us"
    assert response =~ "Book a Room"

    # Check search form elements
    assert response =~ "Location"
    assert response =~ "Property Type"
    assert response =~ "Max Price"
    assert response =~ "Search"
  end

  test "GET / returns successful response", %{conn: conn} do
    conn = get(conn, "/")
    assert response = html_response(conn, 200)
    assert response
  end

  test "GET / contains navigation elements", %{conn: conn} do
    conn = get(conn, "/")
    response = html_response(conn, 200)

    # Check for navigation links
    assert response =~ "Admin Login"
    assert response =~ "Tenant Register"
    assert response =~ "Tenant Login"
  end

  test "GET / has correct page structure", %{conn: conn} do
    conn = get(conn, "/")
    response = html_response(conn, 200)

    # Check for key structural elements
    assert response =~ "<nav"
    assert response =~ "<footer"
    assert response =~ "bg-white"
    assert response =~ "bg-gray-50"
  end
end
