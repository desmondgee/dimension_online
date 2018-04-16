defmodule DimensionOnlineWeb.WorldView do
  use DimensionOnlineWeb, :view

  def current_turn do
    %{turn: turn} = :sys.get_state(DimensionOnline.TurnServer)
    turn
  end

  def creatures do
    # DimensionOnline.Repo.all(DimensionOnline.Creature)
    DimensionOnline.Creature.all_rabbits(current_turn())
  end

  def creature_count do
    DimensionOnline.Creature.count_rabbits(current_turn())
  end

  def dead_creature_count do
    DimensionOnline.Creature.count_dead_rabbits(current_turn())
  end

  def age(creature) do
    current_turn() - creature.birthed_at
  end
end
