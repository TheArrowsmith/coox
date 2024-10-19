defmodule Coox.Recipes do
  @moduledoc """
  The Recipes context.
  """

  import Ecto.Query, warn: false
  alias Coox.Repo

  alias Coox.Accounts.User
  alias Coox.Recipes.Ingredient
  alias Coox.Recipes.Recipe

  def list_recipes(%User{} = user) do
    Repo.all(from Recipe, where: [user_id: ^user.id], preload: [:ingredients])
  end

  def get_recipe!(id, %User{} = user) do
    ingredient_query = from(i in Ingredient, order_by: [asc: :order])

    Repo.one!(
      from(Recipe, where: [id: ^id, user_id: ^user.id], preload: [ingredients: ^ingredient_query])
    )
  end

  def create_recipe(attrs \\ %{}, %User{} = user) do
    %Recipe{user: user}
    |> Recipe.changeset(attrs)
    |> Repo.insert()
  end

  def update_recipe(%Recipe{user_id: uid} = recipe, attrs, %User{id: uid}) do
    recipe
    |> Recipe.changeset(attrs)
    |> Repo.update()
  end

  def update_recipe_image_path!(%Recipe{user_id: uid} = recipe, image_path, %User{id: uid}) do
    recipe |> Ecto.Changeset.change(%{image_path: image_path}) |> Repo.update!()
  end

  def delete_recipe(%Recipe{user_id: uid} = recipe, %User{id: uid}) do
    Repo.delete(recipe)
  end

  def change_recipe(%Recipe{} = recipe, attrs \\ %{}) do
    Recipe.changeset(recipe, attrs)
  end
end
