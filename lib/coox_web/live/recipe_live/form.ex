defmodule CooxWeb.RecipeLive.Form do
  use CooxWeb, :live_view

  alias Coox.Recipes
  alias Coox.Recipes.Recipe

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>{@page_title}</.header>

      <.form for={@form} id="recipe-form">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />

        <div class="flex">
          <.button>Save Recipe</.button>
        </div>
      </.form>

      <.back navigate={~p"/"}>Back</.back>
    </Layouts.app>
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
