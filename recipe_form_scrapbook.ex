@impl true
def mount(params, _session, socket) do
  {:ok,
   socket
   |> apply_action(socket.assigns.live_action, params)}
end

def handle_event("save", %{"recipe" => recipe_params}, socket) do
  save_recipe(socket, socket.assigns.live_action, recipe_params)
end

defp save_recipe(socket, :edit, recipe_params) do
  case Recipes.update_recipe(socket.assigns.recipe, recipe_params) do
    {:ok, recipe} ->
      {:noreply,
       socket
       |> put_flash(:info, "Recipe updated successfully")
       |> push_navigate(to: ~p"/recipes/#{recipe}")}

    {:error, %Ecto.Changeset{} = changeset} ->
      {:noreply, assign(socket, form: to_form(changeset))}
  end
end

defp save_recipe(socket, :new, recipe_params) do
  case Recipes.create_recipe(recipe_params) do
    {:ok, recipe} ->
      {:noreply,
       socket
       |> put_flash(:info, "Recipe created successfully")
       |> push_navigate(to: ~p"/recipes/#{recipe}")}

    {:error, %Ecto.Changeset{} = changeset} ->
      {:noreply, assign(socket, form: to_form(changeset))}
  end
end

defp return_path(%Recipe{id: nil}), do: ~p"/"
defp return_path(recipe), do: ~p"/recipes/#{recipe}"
