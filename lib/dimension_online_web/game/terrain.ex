defmodule DimensionOnlineWeb.Game.Terrain do
  defstruct [
    :name
  ]

  @type t :: %{
    name: String.t()
  }
end
