defmodule DimensionOnlineWeb.Game.TileMap do
  defstruct [:grid, :width]

  def init(width, default_tile \\ :land) do
    grid = for _x <- 0..(width-1) do
      for _y <- 0..(width-1) do
        default_tile
      end
    end

    %__MODULE__{grid: grid, width: width}
  end

  def set_tile(map, x, y, tile) do
    update_grid = List.update_at(map.grid, x, fn column -> List.replace_at(column, y, tile) end)
    put_in(map.grid, update_grid)
  end

  def check_tile(map, {x, y}) do
    column = Enum.at(map.grid, x)
    Enum.at(column, y)
  end

  @directions [
    {-1, 0},
    {1, 0},
    {0, -1},
    {0, 1}
  ]

  def find_neighbors(map, {x, y}) do
    neighbors = for {dir_x, dir_y} <- @directions do
      neighbor_x = x + dir_x
      neighbor_y = y + dir_y
      if neighbor_x in 0..(map.width - 1) && neighbor_y in 0..(map.width - 1) do
       {neighbor_x, neighbor_y, check_tile(map, {neighbor_x, neighbor_y})}
      else
        nil
      end
    end

    Enum.filter(neighbors, & &1 != nil)
  end

  def find_matching_neighbors(map, {x, y}, match_tile) do
    neighbors = find_neighbors(map, {x, y})
    Enum.reduce(neighbors, [], fn {_, _, tile} = neighbor, matching_neighbors ->
      if tile == match_tile do
        [neighbor | matching_neighbors]
      else
        matching_neighbors
      end
    end)
  end

  def print(map) do
    column_text = for column <- map.grid do
      row = for tile <- column do
        case tile do
          :land -> "-"
          :water -> "W"
        end
      end

      Enum.join(row)
    end

    Phoenix.HTML.raw(Enum.join(column_text, "<br/>"))
  end
end
