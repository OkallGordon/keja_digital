defmodule KejaDigitalWeb.PropertyController do
  use KejaDigitalWeb, :controller

  def available(conn, _params) do
    render(conn, :available, layout: false)
  end

  def pricing(conn, _params) do
    render(conn, :pricing, layout: false)
  end
end
