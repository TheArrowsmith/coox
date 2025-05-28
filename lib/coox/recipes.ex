defmodule Coox.Recipes do
  @moduledoc """
  The Recipes context.
  """

  import Ecto.Query, warn: false
  alias Coox.Repo

  alias Coox.Accounts.Scope
  alias Coox.Recipes.Recipe

  def list_recipes(%Scope{} = scope) do
    Repo.all(from Recipe, where: [user_id: ^scope.user.id], preload: [:ingredients])
  end

  def get_recipe!(%Scope{} = scope, id) do
    Repo.one!(from(Recipe, where: [id: ^id, user_id: ^scope.user.id], preload: :ingredients))
  end

  def create_recipe(%Scope{} = scope, attrs \\ %{}) do
    %Recipe{user: scope.user}
    |> Recipe.changeset(attrs)
    |> Repo.insert()
  end

  def update_recipe(%Scope{user: %{id: uid}}, %Recipe{user_id: uid} = recipe, attrs) do
    recipe
    |> Recipe.changeset(attrs)
    |> Repo.update()
  end

  def update_recipe_image_path!(%Scope{user: %{id: uid}}, %Recipe{user_id: uid} = recipe, image_path) do
    recipe |> Ecto.Changeset.change(%{image_path: image_path}) |> Repo.update!()
  end

  def delete_recipe(%Scope{user: %{id: uid}}, %Recipe{user_id: uid} = recipe) do
    Repo.delete(recipe)
  end

  def change_recipe(%Recipe{} = recipe, attrs \\ %{}) do
    Recipe.changeset(recipe, attrs)
  end
end
