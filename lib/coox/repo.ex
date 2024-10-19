defmodule Coox.Repo do
  use Ecto.Repo,
    otp_app: :coox,
    adapter: Ecto.Adapters.Postgres
end
