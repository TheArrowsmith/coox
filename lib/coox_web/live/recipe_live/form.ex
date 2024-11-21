defmodule CooxWeb.RecipeLive.Form do
  use CooxWeb, :live_view

  alias Coox.Recipes
  alias Coox.Recipes.Recipe

  def render(assigns) do
    ~H"""
    <.header><%= @page_title %></.header>

    <.simple_form for={@form} id="recipe-form" phx-change="validate" phx-submit="save">
      <.input field={@form[:name]} type="text" label="Name" phx-debounce />
      <.input
        field={@form[:description]}
        type="textarea"
        label="Description"
        phx-debounce
        phx-hook="MaintainHeight"
      />
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

  def mount(params, _session, socket) do
    {:ok,
     socket
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    recipe = Recipes.get_recipe!(id, socket.assigns.current_user)

    socket
    |> assign(:page_title, "Edit Recipe")
    |> assign(:recipe, recipe)
    |> assign(:form, to_form(Recipes.change_recipe(recipe)))
  end

  defp apply_action(socket, :new, _params) do
    recipe = %Recipe{}

    socket
    |> assign(:page_title, "New Recipe")
    |> assign(:recipe, recipe)
    |> assign(:form, to_form(Recipes.change_recipe(recipe)))
  end

  def handle_event("save", %{"recipe" => recipe_params}, socket) do
    case save_recipe(socket, socket.assigns.live_action, recipe_params) do
      {:ok, recipe} ->
        flash_msg =
          case socket.assigns.live_action do
            :new -> "Recipe created successfully"
            :edit -> "Recipe updated successfully"
          end

        {:noreply,
         socket
         |> put_flash(:info, flash_msg)
         |> push_navigate(to: ~p"/recipes/#{recipe}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("validate", %{"recipe" => recipe_params}, socket) do
    changeset = Recipes.change_recipe(socket.assigns.recipe, recipe_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  defp save_recipe(socket, :edit, recipe_params) do
    Recipes.update_recipe(socket.assigns.recipe, recipe_params, socket.assigns.current_user)
  end

  defp save_recipe(socket, :new, recipe_params) do
    Recipes.create_recipe(recipe_params, socket.assigns.current_user)
  end
end
