defmodule DimensionOnlineWeb.Game.World do
  @grid_radius 35

  def grid_radius, do: @grid_radius

  def current_turn() do
    try do
      %{turn: turn} = :sys.get_state(DimensionOnline.TurnServer)
      turn
    rescue
      e in ArgumentError ->
        IO.warn(e)
    end
  end

  def creatures do
    # DimensionOnline.Repo.all(DimensionOnline.Creature)
    DimensionOnline.Creature.all_rabbits(current_turn())
  end

  def sorted_creatures do
    rabbits = creatures()
    Enum.sort(rabbits, &(&1.coord_x < &2.coord_x || (&1.coord_x == &2.coord_x && &1.coord_y < &2.coord_y)))
  end
end
