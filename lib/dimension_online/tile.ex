defmodule DimensionOnline.Tile do
  use Ecto.Schema
  import Ecto.Changeset


  schema "tiles" do
    field :coord_x, :integer
    field :coord_y, :integer
    field :grass_level, :integer

    timestamps()
  end

  @doc false
  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:coord_x, :coord_y, :grass_level])
  end
end
