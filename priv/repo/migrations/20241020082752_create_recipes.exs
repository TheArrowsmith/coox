defmodule Coox.Repo.Migrations.CreateRecipes do
  use Ecto.Migration

  def change do
    create table(:recipes) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :name, :text, null: false
      add :description, :text
      add :image_path, :string
      add :instructions, :map
      add :rating, :float

      timestamps(type: :utc_datetime)
    end
  end
end
