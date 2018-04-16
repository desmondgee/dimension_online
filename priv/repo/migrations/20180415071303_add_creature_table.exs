defmodule DimensionOnline.Repo.Migrations.AddCreatureTable do
  use Ecto.Migration

  def change do
    create table(:creatures) do
      add :type, :string
      add :food, :integer
      add :food_cap, :integer
      add :coord_x, :integer
      add :coord_y, :integer
      add :birthed_at, :integer
      add :matures_at, :integer
      add :dies_at, :integer
      add :last_message, :string
      add :status, :string

      timestamps()
    end
  end
end
