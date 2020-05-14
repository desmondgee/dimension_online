defmodule DimensionOnlineWeb.Router do
  use DimensionOnlineWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DimensionOnlineWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/hello", HelloController, :index
    get "/hello/:message", HelloController, :show
    get "/world", WorldController, :index
    get "/grid", WorldController, :grid
    get "/terrain", TerrainController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", DimensionOnlineWeb do
  #   pipe_through :api
  # end
end
