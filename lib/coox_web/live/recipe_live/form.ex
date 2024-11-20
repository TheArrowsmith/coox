defmodule CooxWeb.RecipeLive.Form do
  use CooxWeb, :live_view

  alias Coox.Recipes
  alias Coox.Recipes.Recipe

  def render(assigns) do
    ~H"""
    <.header><%= @page_title %></.header>

    <.simple_form for={@form} id="recipe-form" phx-change="validate" phx-submit="save">
      <.input field={@form[:name]} type="text" label="Name" phx-debounce />
      <.input field={@form[:description]} type="textarea" label="Description" phx-debounce phx-hook="MaintainHeight" />
      <:actions>
        <div class="flex">
          <.button phx-disable-with="Saving...">Save Recipe</.button>
          <.loading_spinner class="hidden phx-submit-loading:inline-block ml-4 mb-5" />
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

  def handle_event("save", %{"recipe" => recipe_params}, socket) do
    case Recipes.create_recipe(recipe_params, socket.assigns.current_user) do
      {:ok, recipe} ->
        {:noreply,
         socket
         |> put_flash(:info, "Recipe created successfully")
         |> push_navigate(to: ~p"/recipes/#{recipe}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("validate", %{"recipe" => recipe_params}, socket) do
    changeset = Recipes.change_recipe(socket.assigns.recipe, recipe_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end
end
