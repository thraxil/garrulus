defmodule GarrulusWeb.PageController do
  use GarrulusWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
