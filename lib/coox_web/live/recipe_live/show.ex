defmodule CooxWeb.RecipeLive.Show do
  use CooxWeb, :live_view

  alias Coox.Recipes

  @impl true
  def render(assigns) do
    ~H"""
    <div class="border-b-2 border-zinc-200 pb-4 mb-4">
      <div :if={@recipe.image_path} class="mb-6 flex justify-center">
        <img src={~p"/uploads/#{@recipe.image_path}"} alt={@recipe.name} class="w-1/2 h-auto" />
      </div>

      <.header>
        <%= @recipe.name %>
        <:actions>
          <.link navigate={~p"/recipes/#{@recipe}/edit"} class="text-sm text-zinc-700">
            Edit recipe
          </.link>
        </:actions>
      </.header>
    </div>

    <div :if={@recipe.rating} class="mb-6">
      <h2 class="text-lg font-semibold text-zinc-700">Rating</h2>
      <div
        class="mt-2 flex w-full"
        data-raty
        data-read-only="true"
        data-score={@recipe.rating}
        id="recipe_rating"
        phx-update="ignore"
      >
      </div>
    </div>

    <div :if={@recipe.description} class="mb-6">
      <h2 class="text-lg font-semibold text-zinc-700">Description</h2>
      <p class="text-zinc-600 mt-2"><%= @recipe.description %></p>
    </div>

    <div :if={Enum.any?(@recipe.ingredients)} class="mb-6">
      <h2 class="text-lg font-semibold text-zinc-700">Ingredients</h2>
      <ul class="list-disc list-inside mt-2 text-zinc-600">
        <li :for={ingredient <- @recipe.ingredients}><%= ingredient.name %></li>
      </ul>
    </div>

    <div :if={Enum.any?(@recipe.instructions)} class="mb-6">
      <h2 class="text-lg font-semibold text-zinc-700">Instructions</h2>
      <ol class="list-decimal list-inside mt-2 text-zinc-600">
        <li :for={instruction <- @recipe.instructions}><%= instruction.description %></li>
      </ol>
    </div>

    <.back navigate={~p"/"}>Back to recipes</.back>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Show Recipe")
     |> assign(:recipe, Recipes.get_recipe!(id, socket.assigns.current_user))}
  end
end
