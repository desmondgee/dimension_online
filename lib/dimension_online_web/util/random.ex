defmodule DimensionOnlineWeb.Util.Random do
  def seed(seed) when is_binary(seed), do: seed(:binary.decode_unsigned(seed))
  def seed(seed) when is_integer(seed) do
    :random.seed(seed)
    :random.uniform(9_223_372_036_854_775_807)
  end

  def make_seed() do
    DateTime.utc_now
    |> DateTime.to_unix
    |> Kernel.+(501720171)  # random number for obfuscating seed
  end

  def sample!(%{first: first, last: last}) when last < first, do: sample!(%{first: last, last: first})
  def sample!(%{first: first, last: last}), do: :random.uniform(last - first + 1) + first - 1
  def sample!([]), do: nil
  def sample!(enum), do: Enum.at(enum, :random.uniform(length(enum)) - 1)

  def sample(value, seed) do
    next_seed = seed(seed)
    {sample!(value), next_seed}
  end
end
