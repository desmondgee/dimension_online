defmodule DimensionOnlineWeb.WorldView do
  use DimensionOnlineWeb, :view

  @pan_distance 20

  def print_creatures(%{creatures: creatures, x: x, y: y, hw: hw}) do
    grid = for y <- (y - hw)..(y + hw) do
      row = for x <- (x - hw)..(x + hw) do
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

  def find_creature(creatures, x, y) do
    Enum.find(creatures, &(&1.coord_x == x && &1.coord_y == y))
  end

  def age(creature, turn) do
    turn - creature.birthed_at
  end

  def left_params(%{x: x, y: y}) do
    %{
      x: x - @pan_distance,
      y: y
    }
  end

  def right_params(%{x: x, y: y}) do
    %{
      x: x + @pan_distance,
      y: y
    }
  end

  def up_params(%{x: x, y: y}) do
    %{
      x: x,
      y: y - @pan_distance
    }
  end

  def down_params(%{x: x, y: y}) do
    %{
      x: x,
      y: y + @pan_distance
    }
  end

  def coords_text(%{x: x, y: y}) do
    "(#{x}, #{y})"
  end
end
