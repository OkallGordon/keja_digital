defmodule KejaDigitalWeb.LegalController do
  use KejaDigitalWeb, :controller

  def privacy(conn, _params) do
    render(conn, :privacy, layout: false)
  end
end
