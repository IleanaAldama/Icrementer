defmodule Incrementer.IncrementParams do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :key, :string
    field :value, :float
  end

  def validate(params) do
    %__MODULE__{}
    |> cast(params, [:key, :value])
    |> validate_required([:key, :value])
    |> case do
      %{valid?: true} = changeset ->
        apply_changes(changeset)

      changeset ->
        changeset
    end
  end
end
