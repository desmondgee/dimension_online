defmodule DimensionOnline.Repo.Migrations.CreateTilesTable do
  use Ecto.Migration

  def change do
    create table(:tiles) do
      add :coord_x, :integer
      add :coord_y, :integer
      add :grass_level, :integer

      timestamps()
    end
  end
end
