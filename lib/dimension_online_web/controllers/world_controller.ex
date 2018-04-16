defmodule DimensionOnlineWeb.WorldController do
  use DimensionOnlineWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
