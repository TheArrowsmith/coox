defmodule Coox.Repo.Migrations.CreateIngredients do
  use Ecto.Migration

  def change do
    create table(:ingredients) do
      add :name, :string, null: false
      add :recipe_id, references(:recipes, on_delete: :delete_all), null: false
      add :order, :integer, default: 0, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:ingredients, [:recipe_id])
  end
end
