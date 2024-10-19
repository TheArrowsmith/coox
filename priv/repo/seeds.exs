# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Coox.Repo.insert!(%Coox.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Coox.Accounts
alias Coox.Accounts.User
alias Coox.Repo
alias Coox.Recipes.Recipe
alias Coox.Recipes.Ingredient
alias Coox.Recipes.Instruction

File.mkdir_p("priv/static/uploads")

File.copy!(
  "priv/static/images/spaghetti-carbonara.jpg",
  "priv/static/uploads/spaghetti-carbonara.jpg"
)

if user = Repo.get_by(User, email: "test@example.com") do
  Repo.delete(user)
end

{:ok, user} = Accounts.register_user(%{email: "test@example.com", password: "password1234"})

%Recipe{
  name: "Spaghetti Carbonara",
  description:
    "A classic Italian pasta dish made with eggs, cheese, pancetta, and black pepper. Perfect for a comforting and quick dinner!",
  user: user,
  rating: 3.5,
  image_path: "spaghetti-carbonara.jpg",
  ingredients: [
    %Ingredient{name: "200g Spaghetti", order: 0},
    %Ingredient{name: "100g Pancetta", order: 1},
    %Ingredient{name: "2 Large Eggs", order: 2},
    %Ingredient{name: "50g Pecorino Cheese (grated)", order: 3},
    %Ingredient{name: "Black Pepper", order: 4},
    %Ingredient{name: "Salt", order: 5}
  ],
  instructions: [
    %Instruction{
      description: "Bring a pot of salted water to the boil, cook the spaghetti until al dente."
    },
    %Instruction{
      description:
        "While the pasta is cooking, beat the eggs in a bowl and add the grated Pecorino cheese, mix together."
    },
    %Instruction{description: "In a frying pan, cook the pancetta until crispy."},
    %Instruction{description: "Drain the pasta and reserve some of the pasta water."},
    %Instruction{
      description:
        "Quickly toss the spaghetti with the pancetta, then remove from the heat and slowly mix in the egg and cheese mixture."
    },
    %Instruction{
      description:
        "Add a dash of pasta water to create a creamy sauce. Season with black pepper and serve immediately."
    }
  ]
}
|> Repo.insert!()
