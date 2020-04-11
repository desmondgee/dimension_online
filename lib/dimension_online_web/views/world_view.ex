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

  def sorted_creatures do
    rabbits = creatures()
    Enum.sort(rabbits, &(&1.coord_x < &2.coord_x || (&1.coord_x == &2.coord_x && &1.coord_y < &2.coord_y)))
  end

  def find_creature(creatures, x, y) do
    Enum.find(creatures, &(&1.coord_x == x && &1.coord_y == y))
  end

  def print_creatures do
    radius = 35
    creatures = creatures()
    grid = for y <- -radius..radius do
      row = for x <- -radius..radius do
        if find_creature(creatures, x, y) do
          "O"
        else
          "-"
        end
      end

      Enum.join(row)
    end

    Phoenix.HTML.raw(Enum.join(grid, "<br/>"))
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
