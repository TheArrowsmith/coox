defmodule CooxWeb.RecipeLive.Form do
  use CooxWeb, :live_view

  alias Coox.Recipes
  alias Coox.Recipes.Recipe

  def render(assigns) do
    ~H"""
    <.header><%= @page_title %></.header>

    <.simple_form for={@form} id="recipe-form" phx-change="validate" phx-submit="save">
      <div>
        <.label>Image</.label>

        <div
          :if={@recipe.image_path && Enum.empty?(@uploads.image.entries)}
          class="mb-6 flex justify-center"
        >
          <img src={~p"/uploads/#{@recipe.image_path}"} alt="Recipe image" class="w-1/2 h-auto" />
        </div>

        <%= for entry <- @uploads.image.entries do %>
          <figure class="flex justify-around">
            <div class="relative">
              <.live_img_preview entry={entry} class="rounded max-h-64 shadow" />
              <figcaption class="text-center text-sm text-gray-700 mt-2">
                <%= entry.client_name %>
              </figcaption>
              <button
                aria-label="cancel"
                class="absolute top-1 right-2"
                phx-click="cancel-upload"
                phx-value-ref={entry.ref}
                type="button"
              >
                &times;
              </button>
            </div>
          </figure>
        <% end %>

        <.live_file_input upload={@uploads.image} class="hidden" />

        <label
          class="flex flex-col items-center justify-center w-full h-64 border-2 border-gray-300 border-dashed rounded-lg cursor-pointer bg-gray-50 hover:bg-gray-100 mt-2"
          for={@uploads.image.ref}
          phx-drop-target={@uploads.image.ref}
        >
          <div class="flex flex-col items-center justify-center pt-5 pb-6">
            <.icon name="hero-arrow-up-tray" class="w-8 h-8 mb-4 text-gray-500" />
            <p class="mb-2 text-sm text-gray-500">
              <span class="font-semibold">Click to upload</span> or drag and drop
            </p>
            <p class="text-xs text-gray-500">
              PNG or JPG (Max. 2Mb)
            </p>
          </div>
        </label>
      </div>

      <.input field={@form[:name]} type="text" label="Name" phx-debounce />

      <div>
        <.label>Rating</.label>
        <div
          class="mt-2 flex w-full"
          data-raty
          data-score-name={@form[:rating].name}
          data-score={@form[:rating].value}
          id={@form[:rating].id}
          phx-update="ignore"
        >
        </div>
      </div>

      <.input
        field={@form[:description]}
        type="textarea"
        label="Description"
        phx-debounce
        phx-hook="MaintainHeight"
      />

      <div class="mb-6">
        <h2 class="text-lg font-semibold text-zinc-700">Instructions</h2>

        <div id="instruction-inputs">
          <.inputs_for :let={instruction_f} field={@form[:instructions]}>
            <div class="flex items-center mt-4 mb-2 space-x-2">
              <div class="grow">
                <.input field={instruction_f[:description]} type="text" phx-debounce />
              </div>
            </div>
          </.inputs_for>
        </div>
      </div>

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
     |> allow_upload(:image,
       accept: ~w(.png .jpg),
       max_entries: 1,
       max_file_size: 2 * 1024 * 1024
     )
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

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  @uploads_dir Path.join([:code.priv_dir(:coox), "static", "uploads"])

  def handle_event("save", %{"recipe" => recipe_params}, socket) do
    case save_recipe(socket, socket.assigns.live_action, recipe_params) do
      {:ok, recipe} ->
        image_path =
          socket
          |> consume_uploaded_entries(:image, fn %{path: path}, _entry ->
            dest = Path.join(@uploads_dir, Path.basename(path))
            File.cp!(path, dest)
            {:ok, Path.basename(dest)}
          end)
          |> List.first()

        if image_path do
          Recipes.update_recipe_image_path!(recipe, image_path, socket.assigns.current_user)
        end

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
