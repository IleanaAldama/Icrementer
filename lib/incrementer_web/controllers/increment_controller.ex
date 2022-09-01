defmodule IncrementerWeb.IncrementController do
  use IncrementerWeb, :controller
  alias Incrementer.Increment, as: Params
  alias JaSerializer.EctoErrorSerializer

  @doc false
  def increment(conn, params) do
    with %{key: key, value: value} <- Params.validate(params),
         :ok <- Incrementer.increment(key, value) do
      send_resp(conn, 202, "")
    else
      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{errors: [reason]})

      %{valid?: false, errors: errors} ->
        conn
        |> put_status(400)
        |> json(EctoErrorSerializer.format(errors))
    end
  end
end
