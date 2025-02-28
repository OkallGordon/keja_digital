defmodule KejaDigitalWeb.BookinglHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use KejaDigitalWeb, :html

  embed_templates "booking/*"
end
