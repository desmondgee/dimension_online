defmodule DimensionOnlineWeb.WorldController do
  use DimensionOnlineWeb, :controller
  alias DimensionOnline.Creature
  alias DimensionOnlineWeb.Game.World

  @hw 35

  def index(conn, _params) do
    turn = World.current_turn()

    assigns = %{
      turn: turn,
      alive_count: Creature.count_rabbits(turn),
      dead_count: Creature.count_dead_rabbits(turn)
    }

    render conn, "index.html", assigns
  end

  def grid(conn, params) do
    turn = World.current_turn()

    assigns = %{
      turn: turn,
      x: coord_x(params),
      y: coord_y(params),
      hw: @hw,
      alive_count: Creature.count_rabbits(turn),
      dead_count: Creature.count_dead_rabbits(turn)
    }

    creatures = Creature.rabbits(assigns)
    assigns = Map.put(assigns, :creatures, creatures)

    conn = put_layout conn, false

    render conn, "grid.html", assigns
  end

  def coord_x(%{"x" => x}), do: String.to_integer(x)
  def coord_x(_), do: 0

  def coord_y(%{"y" => y}), do: String.to_integer(y)
  def coord_y(_), do: 0
end
