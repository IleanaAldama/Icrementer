defmodule Incrementer.Repo do
  use Ecto.Repo,
    otp_app: :incrementer,
    adapter: Ecto.Adapters.Postgres
end
