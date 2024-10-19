defmodule Coox.Recipes.Ingredient do
  use Ecto.Schema
  import Ecto.Changeset

  alias Coox.Recipes.Recipe

  schema "ingredients" do
    field :name, :string
    field :order, :integer, default: 0

    belongs_to :recipe, Recipe

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ingredient, attrs) do
    ingredient
    |> cast(attrs, [:name, :order])
    |> validate_required([:name])
  end
end
