defmodule CooxWeb.RecipeLive.Form do
  use CooxWeb, :live_view

  alias Coox.Recipes
  alias Coox.Recipes.Recipe

  def render(assigns) do
    ~H"""
    <.header>{@page_title}</.header>

    <.simple_form for={@form} id="recipe-form">
      <.input field={@form[:name]} type="text" label="Name" />
      <.input field={@form[:description]} type="textarea" label="Description" />

      <:actions>
        <div class="flex">
          <.button>Save Recipe</.button>
        </div>
      </:actions>
    </.simple_form>

    <.back navigate={~p"/"}>Back</.back>
    """
  end

  def mount(_params, _session, socket) do
    recipe = %Recipe{}

    {:ok,
     socket
     |> assign(:page_title, "New Recipe")
     |> assign(:recipe, recipe)
     |> assign(:form, to_form(Recipes.change_recipe(recipe)))}
  end
end
