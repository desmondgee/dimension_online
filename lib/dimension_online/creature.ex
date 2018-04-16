defmodule DimensionOnline.Creature do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
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
    field :last_message, :string
    field :status, :string

    timestamps()
  end

  @doc false
  def changeset(creature, params \\ %{}) do
    creature
    |> cast(params, [:type, :food, :food_cap, :coord_x, :coord_y, :birthed_at, :matures_at, :dies_at, :last_message, :status])
  end

  def all_rabbits(ticker) do
    Repo.all(from c in Creature, where: c.type == "Rabbit" and c.dies_at >= ^ticker)
  end

  def count_rabbits(ticker) do
    Repo.one(from c in Creature, where: c.type == "Rabbit" and c.dies_at >= ^ticker, select: count("*"))
  end

  def count_dead_rabbits(ticker) do
    Repo.one(from c in Creature, where: c.type == "Rabbit" and c.dies_at < ^ticker, select: count("*"))
  end

  def spawn_rabbit(ticker, changeset \\ %{}) do
    creature = %Creature{
      type: "Rabbit",
      food: Enum.random(1..8),
      food_cap: 8,
      coord_x: Enum.random(-100..100),
      coord_y: Enum.random(-100..100),
      birthed_at: ticker,
      matures_at: ticker + Enum.random(10..14),
      dies_at: ticker + Enum.random(22..30)
    }

    Repo.insert(change(creature, changeset))
  end

  def tick_all(ticker) do
    for raw <- Repo.all(Creature) do
      creature = change(raw)
      |> take_action(ticker)
      |> burn_energy

      cond do
        birthing?(creature, ticker) ->
          fission_birth(creature, ticker)
          Repo.delete(creature)
        dying?(creature, ticker) ->
          Repo.update(change(creature, dies_at: ticker, last_message: "is dying"))
          # Repo.delete(creature)
        true ->
          Repo.update(creature)
      end

    end
  end

  defp fission_birth(creature, ticker) do
    x = get_field(creature, :coord_x)
    y = get_field(creature, :coord_y)
    id = get_field(creature, :id)
    status = "Fission birthed from creature \##{id}"
    change = %{coord_x: x, coord_y: y, last_message: status}
    spawn_rabbit(ticker, change)
    spawn_rabbit(ticker, change)
  end

  defp birthing?(creature, ticker) do
    mature?(creature, ticker) && get_field(creature, :food) >= get_field(creature, :food_cap) * 1.4
  end

  defp dying?(creature, ticker) do
    (get_field(creature, :dies_at) <= ticker) || (get_field(creature, :food) <= 0)
  end

  defp burn_energy(creature) do
    food = get_field(creature, :food)
    change(creature, food: food - 1)
  end

  defp take_action(creature, ticker) do
    if bloated?(creature, ticker) do
      status = get_status(creature, "is feeling bloated.")
      change(creature, last_message: status)
    else
      possible_actions = [&graze/1, &roam/1]
      action = Enum.random(possible_actions)
      action.(creature)
    end
  end

  defp graze(creature) do
    increment = Enum.random([0, 0, 1, 2, 3, 3, 4, 4])
    if increment == 0 do
      status = get_status(creature, "was unable to find food.")
      change(creature, last_message: status)
    else
      status = get_status(creature, "grazes and consumes #{increment} food.")
      change(creature,
        food: get_field(creature, :food) + increment,
        last_message: status
      )
    end
  end

  defp roam(creature) do
    x = traverse(get_field(creature, :coord_x))
    y = traverse(get_field(creature, :coord_y))
    status = get_status(creature, "travels to (#{x}, #{y})")

    change(creature, coord_x: x, coord_y: y, last_message: status)
  end

  defp traverse(pos) do
    pos + Enum.random([-1, 0, 1])
  end

  defp bloated?(creature, ticker) do
    if mature?(creature, ticker) do
      false
    else
      get_field(creature, :food) >= get_field(creature, :food_cap)
    end
  end

  defp mature?(creature, ticker) do
    get_field(creature, :matures_at) <= ticker
  end

  defp get_status(creature, message) do
    type = get_field(creature, :type)
    id = get_field(creature, :id)
    name = "#{type} \##{id}"

    if hungry?(creature) do
      "Feeling hungry and #{message}"
    else
      message
    end
  end

  defp hungry?(creature) do
    get_field(creature, :food) <= 3
  end
end
