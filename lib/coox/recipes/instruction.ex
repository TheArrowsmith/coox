defmodule Coox.Recipes.Instruction do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :description, :string
  end

  @doc false
  def changeset(instruction, attrs) do
    instruction
    |> cast(attrs, [:description])
    |> validate_required([:description])
  end
end
