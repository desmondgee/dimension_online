defmodule DimensionOnlineWeb.HelloController do
  use DimensionOnlineWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def show(conn, %{"message" => message}) do
    render conn, "show.html", message: message
  end
end
