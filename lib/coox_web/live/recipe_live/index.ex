defmodule CooxWeb.RecipeLive.Index do
  use CooxWeb, :live_view

  alias Coox.Recipes

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      <%= @page_title %>
      <:actions>
        <.button phx-click={JS.navigate(~p"/recipes/new")} class="flex items-center">
          <.icon name="hero-plus" class="h-4 w-4" />Add new
        </.button>
      </:actions>
    </.header>

    <.table
      id="recipes"
      rows={@streams.recipes}
      row_click={fn {_id, recipe} -> JS.navigate(~p"/recipes/#{recipe}") end}
    >
      <:col :let={{_id, recipe}} class="w-32">
        <img
          :if={recipe.image_path}
          alt={recipe.name}
          class="rounded"
          width="84"
          height="84"
          src={~p"/uploads/#{recipe.image_path}"}
        />
      </:col>
      <:col :let={{_id, recipe}} label="Name">
        <div class="w-full">
          <%= recipe.name %>
        </div>
      </:col>
      <:action :let={{_id, recipe}}>
        <div class="sr-only">
          <.link navigate={~p"/recipes/#{recipe}"}>Show</.link>
        </div>
        <.link navigate={~p"/recipes/#{recipe}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, recipe}}>
        <.link
          phx-click={JS.push("delete", value: %{id: recipe.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "My recipes")
     |> stream(:recipes, Recipes.list_recipes(socket.assigns.current_user))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    recipe = Recipes.get_recipe!(id, socket.assigns.current_user)
    {:ok, _} = Recipes.delete_recipe(recipe, socket.assigns.current_user)
    {:noreply, stream_delete(socket, :recipes, recipe)}
  end
end
