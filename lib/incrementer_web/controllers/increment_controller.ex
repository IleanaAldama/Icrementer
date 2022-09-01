defmodule IncrementerWeb.IncrementController do
  use IncrementerWeb, :controller
  alias Incrementer.Increment

  def increment(conn, %{"key" => key, "value" => value}) do
    case Incrementer.increment(key, value) do
      :ok ->
        conn
        |> put_status(202)
        |> halt()

      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{error: reason})
    end
  end

  def increment(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{error: "Invalid params; key and value required"})
  end
end
