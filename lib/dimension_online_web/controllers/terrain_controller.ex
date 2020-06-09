defmodule DimensionOnlineWeb.TerrainController do
  use DimensionOnlineWeb, :controller

  alias DimensionOnlineWeb.Game.TileMap
  alias DimensionOnlineWeb.Game.NoiseMap
  alias DimensionOnlineWeb.Util.Random

  def index(conn, _params) do
    # seed = Random.seed("Land of the slime rabbits")
    seed = Random.make_seed() |> Random.seed()
    IO.inspect(seed, label: "USING SEED")

    map_width = 50

    {tile_counts, seed} = generate_terrain_tile_counts(map_width * map_width, seed)
    {map, unused_water_tiles, _seed} = generate_tiles(tile_counts, map_width, seed)

    assigns = %{
      expected_tile_counts: tile_counts,
      actual_tile_counts: %{
        water: tile_counts.water - unused_water_tiles,
        land: tile_counts.land + unused_water_tiles,
        total: tile_counts.total
      },
      map: map,
      printed_tiles: TileMap.print(map)
    }

    conn = put_layout conn, false

    render conn, "index.html", assigns
  end

  @tiles 100

  def simplex(conn, params) do
    zoom = params
    |> Map.get("zoom", "1.0")
    |> Float.parse()
    |> elem(0)

    [coord_x, coord_y] = Map.get(params, "pos", "250.0,250.0") |> String.split(",")
    coord_x = Float.parse(coord_x) |> elem(0)
    coord_y = Float.parse(coord_y) |> elem(0)

    pan_amount = @tiles * 0.5 / zoom

    assigns = %{
      printed_tiles: NoiseMap.print(coord_x, coord_y, @tiles, zoom),
      zoom_in: new_path(conn, coord_x, coord_y, zoom * 1.5),
      zoom_out: new_path(conn, coord_x, coord_y, zoom / 1.5),
      pan_left: new_path(conn, coord_x - pan_amount, coord_y, zoom),
      pan_right: new_path(conn, coord_x + pan_amount, coord_y, zoom),
      pan_up: new_path(conn, coord_x, coord_y - pan_amount, zoom),
      pan_down: new_path(conn, coord_x, coord_y + pan_amount, zoom)
    }
    conn = put_layout conn, false

    render conn, "simplex.html", assigns
  end

  defp new_path(conn, x, y, zoom) do
    params = %{
      pos: "#{x},#{y}",
      zoom: "#{zoom}"
    }

    Routes.terrain_path(conn, :simplex, params)
  end

  def generate_tiles(tile_counts, width, seed) do
    {map, remaining_length, seed} = TileMap.init(width) |> generate_river(tile_counts.water, seed)


  end

  def generate_river(map, length, seed, tries \\ 3) do
    tries = tries - 1
    {start_x, seed} = Random.sample(0..(map.width-1), seed)
    {start_y, seed} = Random.sample(0..(map.width-1), seed)
    updated_map = TileMap.set_tile(map, start_x, start_y, :water)

    {map, remaining_length, seed} = do_generate_river(updated_map, {start_x, start_y}, length - 1, seed)

    if remaining_length == 0 || tries == 0  do
      {map, remaining_length, seed}
    else
      generate_river(map, remaining_length, seed, tries)
    end
  end

  def do_generate_river(map, _, 0, seed), do: {map, 0, seed}
  def do_generate_river(map, {prev_x, prev_y}, remaining_length, seed) do
    possible_tiles = TileMap.find_matching_neighbors(map, {prev_x, prev_y}, :land)

    {random_tile, seed} = Random.sample(possible_tiles, seed)

    case random_tile do
      {tile_x, tile_y, _} ->
        updated_map = TileMap.set_tile(map, tile_x, tile_y, :water)
        do_generate_river(updated_map, {tile_x, tile_y,}, remaining_length - 1, seed)
      nil -> {map, remaining_length, seed}
    end
  end

  def generate_terrain_tile_counts(tile_count, seed) do
    max_water_tiles = trunc(tile_count * 0.2)
    {water_tiles, seed} = Random.sample(0..max_water_tiles, seed)
    land_tiles = tile_count - water_tiles

    {
      %{
        water: water_tiles,
        land: land_tiles,
        total: tile_count
      },
      seed
    }
  end

  @biomes %{
    forest: %{

    }
  }


  def generate_terrain do
    # First create percentages of different terrain
    # terrain types:
    # water
    # sand - fairly course and drains water. poor for plants since doesn't hold water or nutrients(they are washed away) well.
    #   * Good for root vegetables, lettuce, strawberries, peppers, corn, squash, zucchini, collared greens, potatoes.
    # silt - a fine sand. like flour, feels slick and smooth. does okay job holding water.
    #   * Good for most vegetables and moisture loving trees
    # clay - very fine grained. little or no space for water or air to circulate. does not drain well or provide space for roots to grow. good for pottery or brick building. high nutrients.
    #   * Good for fruit trees and summer vegetables
    # loam - a combination of the above. best for farming if composition allows for right amount of water drainage versus retention.
    #   * Good for bamboo, most vegetables, most berries
    #   * Dries out fast and needs crop rotation.
    # peat - high organic matter. retains large amount of water. tends to be more acidic.
    #   * Good for Brassicas, legumes, root crops, salad crops
    # chalk - can be light or heavy. highly alkaline.
    #   * GOod for spinach, beets, sweet corn, cabbage
    #
    # https://en.wikipedia.org/wiki/USDA_soil_taxonomy
    #
    # https://sciencing.com/types-rocks-soil-6659814.html
    #
    # Igneous - cooled magma. Includes granite, obsidian and pumice.
    # Sedimentary - cemented pieces of rock, chemically formed rock or organic material. Includes sandstone, rock gypsum and bituminous coal.
    # Metamorphic - rocks that have changed due to unstable environment. Includes slate, marble, schrist.


    # Simplified types:
    # granite, sandstone,

    # Surface is 75% sedimentary rock, 25% igneous and metamorphic rock
    # http://www.classzone.com/vpg_ebooks/sci_sc_8/accessibility/sci_sc_8/page_80.pdf



  end
end
