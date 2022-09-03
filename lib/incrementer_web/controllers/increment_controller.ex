defmodule IncrementerWeb.IncrementController do
  use IncrementerWeb, :controller
  alias Incrementer.Increment, as: Params
  alias JaSerializer.EctoErrorSerializer

  @doc false
  def increment(conn, params) do
    with %{key: key, value: value} <- Params.validate(params) do
      Incrementer.increment(key, value)
      send_resp(conn, 202, "")
    else
      %{valid?: false, errors: errors} ->
        conn
        |> put_status(400)
        |> json(EctoErrorSerializer.format(errors))
    end
  end
end
