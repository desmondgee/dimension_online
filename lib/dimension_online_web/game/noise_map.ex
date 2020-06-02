defmodule DimensionOnlineWeb.Game.NoiseMap do
  defstruct [:grid, :width]

  alias DimensionOnlineWeb.Game.Simplex

  def print(width) do
    width = 200

    column_text = for y <- 0..(width - 1) do
      row = for x <- 0..(width - 1) do
        height = computeHeight(x, y)
        cond do
          height < 0.2 ->
            "<div class='level-1'></div>"
          height < 0.4 ->
            "<div class='level-2'></div>"
          height < 0.6 ->
            "<div class='level-3'></div>"
          height < 0.8 ->
            "<div class='level-4'></div>"
          true ->
            "<div class='level-5'></div>"
        end
      end

      Enum.join(row)
    end

    Phoenix.HTML.raw(Enum.join(column_text, "<br/>"))
  end


  @offset_x 41.51891
  @offset_y 14.15601

  @base_roughness 0.2

  @roughness 0.8
  @processing_layers 4

  @persistence 2

  def computeHeight(x, y) do
    computeHeight(x, y, 0, @processing_layers, @base_roughness, 1)
  end

  def computeHeight(_, _, height, 0, _, _), do: height

  def computeHeight(x, y, height, layers, frequency, amplitude) do
    noise = Simplex.noise(x * frequency + @offset_x, y * frequency + @offset_y)
    added_height = (noise + 1) * 0.5

    residual_height_ratio = 1 / (amplitude + 1)
    added_height_ratio = 1 - residual_height_ratio
    new_height = height * residual_height_ratio + added_height * added_height_ratio

    computeHeight(x, y, new_height, layers - 1, frequency * @roughness, amplitude * @persistence)
  end

  # first round: max height is 1 * amplitude
  # second round: max height is (1 * amplitude) + (1 * amplitude * persistence)
  # third round: max height is (1 * amplitude) + (1 * amplitude * persistence) + (1 * amplitude * persistence * persistence)
end
