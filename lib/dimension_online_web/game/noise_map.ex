defmodule DimensionOnlineWeb.Game.NoiseMap do
  defstruct [:grid, :width]

  alias DimensionOnlineWeb.Game.Simplex
  alias DimensionOnlineWeb.Game.NoiseLayerSetting

  def print(width) do
    width = 200

    column_text = for y <- 0..(width - 1) do
      row = for x <- 0..(width - 1) do
        height = calculate_height(x, y)
        balanced_world(height)
        # mountain_world(height)
        # grass_world(height)
        # water_world(height)
      end

      Enum.join(row)
    end

    Phoenix.HTML.raw(Enum.join(column_text, "<br/>"))
  end

  def balanced_world(height) do
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

  def mountain_world(height) do
    cond do
      height < 0.25 ->
        "<div class='level-1'></div>"
      height < 0.35 ->
        "<div class='level-2'></div>"
      height < 0.45 ->
        "<div class='level-3'></div>"
      height < 0.7 ->
        "<div class='level-4'></div>"
      true ->
        "<div class='level-5'></div>"
    end
  end

  def grass_world(height) do
    cond do
      height < 0.3 ->
        "<div class='level-1'></div>"
      height < 0.7 ->
        "<div class='level-2'></div>"
      height < 0.8 ->
        "<div class='level-3'></div>"
      height < 0.9 ->
        "<div class='level-4'></div>"
      true ->
        "<div class='level-5'></div>"
    end
  end

  def water_world(height) do
    cond do
      height < 0.5 ->
        "<div class='level-1'></div>"
      height < 0.7 ->
        "<div class='level-2'></div>"
      height < 0.8 ->
        "<div class='level-3'></div>"
      height < 0.9 ->
        "<div class='level-4'></div>"
      true ->
        "<div class='level-5'></div>"
    end
  end

  @land_layer_setting NoiseLayerSetting.default()
  @dome_layer_setting %NoiseLayerSetting{NoiseLayerSetting.default() |
    offset_x: 44358461.74457203,
    offset_y: 91565620.6971831,
    frequency: 0.0082
  }
  @ridge_layer_setting %NoiseLayerSetting{NoiseLayerSetting.default() |
    offset_x: 3113267.54804393,
    offset_y: 5965100.813402789,
    frequency: 0.0031,
    algorithm: :ridge
  }

  # TODO: Make the percentages of these vary along the surface to make exploring interesting.
  def calculate_height(x, y) do
    land_layer_height = calculate_layer_height(x, y, @land_layer_setting)
    dome_layer_height = calculate_layer_height(x, y, @dome_layer_setting)
    ridge_layer_height = calculate_layer_height(x, y, @ridge_layer_setting)

    apply_weights([
      {land_layer_height, 1},
      {land_layer_height * dome_layer_height, 1.5},
      {ridge_layer_height, 3.5}
    ])

  end

  defp apply_weights(list) do
    total_weight = Enum.reduce(list, 0, fn {_, weight}, acc -> acc + weight end)
    Enum.reduce(list, 0, fn {layer_height, weight}, acc -> acc + layer_height *  (weight / total_weight) end)
  end

  defp calculate_layer_height(x, y, setting) do
    noise = Simplex.noise(x * setting.frequency + setting.offset_x, y * setting.frequency + setting.offset_y)

    layer_height = case setting.algorithm do
      :normal ->
        (noise + 1) * 0.5
      :ridge ->
        :math.pow( 1 - abs(noise), 2)
    end

    new_setting = %NoiseLayerSetting{setting |
      frequency: setting.frequency * setting.roughness,
      ratio: setting.ratio * setting.persistence,
      roughening_layers: setting.roughening_layers - 1
    }

    if new_setting.roughening_layers == 0 do
      layer_height
    else
      layer_height * (1 - new_setting.ratio) + calculate_layer_height(x, y, new_setting) * new_setting.ratio
    end
  end
end
