defmodule KejaDigitalWeb.SupportController do
  use KejaDigitalWeb, :controller

  def contact(conn, _params) do
    render(conn, :contact, layout: false)
  end
end
