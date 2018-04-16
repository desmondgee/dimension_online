defmodule DimensionOnline.Creature do
  use Ecto.Schema
  import Ecto.Changeset
  alias DimensionOnline.{Repo, Creature}


  schema "creatures" do
    field :type, :string
    field :food, :integer
    field :food_cap, :integer
    field :coord_x, :integer
    field :coord_y, :integer
    field :birthed_at, :integer
    field :matures_at, :integer
    field :dies_at, :integer

    timestamps()
  end

  @doc false
  def changeset(creature, params \\ %{}) do
    creature
    |> cast(params, [:type, :food, :food_cap, :coord_x, :coord_y, :birthed_at, :matures_at, :dies_at])
  end

  def spawn_rabbit(ticks) do
    Repo.insert(%Creature{
      type: "Rabbit",
      food: Enum.random(1..8),
      food_cap: 8,
      coord_x: Enum.random(-100..100),
      coord_y: Enum.random(-100..100),
      birthed_at: ticks,
      matures_at: ticks + Enum.random(10..14),
      dies_at: ticks + Enum.random(22..30)
    })
  end

  def tick_all(ticks) do
    for creature <- Repo.all(Creature) do
      changeset = change(creature)
      |> take_action(ticks)
      |> burn_energy
      |> check_birthing
      |> check_death

      Repo.update(changeset)
    end
  end

  defp check_birthing(creature) do
    creature
  end

  defp check_death(creature) do
    creature
  end

  defp burn_energy(creature) do
    food = get_field(creature, :food)
    change(creature, food: food - 1)
  end

  defp take_action(creature, ticks) do
    if bloated?(creature, ticks) do
      log(creature, "is feeling bloated.")
      creature
    else
      possible_actions = [&graze/1, &roam/1]
      action = Enum.random(possible_actions)
      action.(creature)
    end
  end

  defp graze(creature) do
    increment = Enum.random([0, 1, 2, 3])
    log(creature, "grazes and consumes #{increment} food.")
    change(creature, food: get_field(creature, :food) + increment)
  end

  defp roam(creature) do
    x = traverse(get_field(creature, :coord_x))
    y = traverse(get_field(creature, :coord_y))
    log(creature, "travels to (#{x}, #{y})")

    change(creature, coord_x: x, coord_y: y)
  end

  defp traverse(pos) do
    pos + Enum.random([-1, 0, 1])
  end

  defp bloated?(creature, ticks) do
    if mature?(creature, ticks) do
      false
    else
      get_field(creature, :food) >= get_field(creature, :food_cap)
    end
  end

  defp mature?(creature, ticks) do
    get_field(creature, :matures_at) <= ticks
  end

  defp log(creature, message) do
    IO.puts "#{name(creature)} #{message}"
  end

  defp name(creature) do
    type = get_field(creature, :type)
    id = get_field(creature, :id)
    "#{type} \##{id}"
  end
end
