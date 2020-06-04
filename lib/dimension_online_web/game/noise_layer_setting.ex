defmodule DimensionOnlineWeb.Game.NoiseLayerSetting do
  defstruct [:offset_x, :offset_y, :frequency, :ratio, :roughness, :roughening_layers, :persistence, :algorithm]

  @typedoc """
  * `:frequency`: Use 1 / (# of terrain tiles between randomized peaks and valleys). 1.0 is effecively white noise for each tile.
  *   If too low, the terrain will be very smooth, but if too high, it will look like white noise. Will look like white noise regardless
  *   if zoomed out enough.
  * `:roughness`: Normally the simplex algoirthm has a purely smooth curve between peaks and valleys. This simulates roughness by adding
  *   another simplex algorithm height calculated at a slightly different scale which in turn makes it seem random as long as x and y isn't
  *   too close to 0. Should be slightly less than 1 to add smoothness and slightly greater than 1 to add more roughness. This can be much
  *   greater than 1 to add much roughness. Imagine two sine waves added together where the second one has its frequency multiplied
  *   by this number.
  * `:roughness_layers`: How many times to apply roughness. Makes the noise smoothing look less predictable by adding more heights at
  *   different frequencies, each multiplied again by the roughness value.
  * `:persistence`: We reduce the impact of roughening with each layer so that the resulting value doesn't get out of hand. This value
  *   should therefore be less than 1. A value of 0.5 makes each additional roughening layer have half the impact of the previous layer
  *   on the final height. If set greater than 0.5, it effectively makes the last roughening layer the most prominent making the base
  *   frequency less useful for determing ideal map scale.
  * `:algorithm`: Can be :normal or :ridge.
  *   * :normal is like a sine wave offset and scaled to the 0 to 1 range.
  *   * :ridge is a the absolute value of a sine save that is then squared making have a wide valley near 0, and sharp peaks at 1.
  """
  @type t() :: %__MODULE__{
    offset_x: integer() | float(),
    offset_y: integer() | float(),
    frequency: float(),
    ratio: float(),
    roughness: float(),
    roughening_layers: 1..10,
    persistence: float(),
    algorithm: :normal | :ridge
  }

  def default do
    %__MODULE__{
      offset_x: 20944855.618709624,
      offset_y: 21497304.823532137,
      frequency: 0.2,
      ratio: 0.5,
      roughness: 1.2,
      roughening_layers: 5,
      persistence: 0.4,
      algorithm: :normal
    }
  end
end
