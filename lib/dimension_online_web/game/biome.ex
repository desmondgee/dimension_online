defmodule DimensionOnlineWeb.Game.Biome do
  alias DimensionOnlineWeb.Game.Biome
  alias DimensionOnlineWeb.Game.Terrain
  defstruct [
    :weight_ranges
  ]

  @type terrain :: :water | :rock | :clay | :silt | :sand

  @type t :: %Biome{
    weight_ranges: %{required(Terrain.t) => integer()}
  }

  def create_tiles(biome, tile_count) do
    weights = for {terrain, weight_range} <- biome.weights, into: %{}, do: {terrain, randomize_weight(weight_range)}
    total_weight = Enum.reduce(weights, 0, fn({_terrain, weight}, acc) -> acc + weight end)

    remaining_tile_count = tile_count
    for {terrain, weight} <- biome.weights, into: %{} do
      terrain_tile_count = (weight / total_weight * tile_count)
      {terrain, total_weight}
    end
  end

  def randomize_weight([min, max]) do
    Enum.random(min..max)
  end

  def forest_biome do
    %Biome{
      weight_ranges: %{
        clay: [1, 10],
        silt: [4, 46],
        sand: [45, 95]
      }
    }
  end
end
