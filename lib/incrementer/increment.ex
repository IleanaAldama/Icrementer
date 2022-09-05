defmodule Incrementer.Increment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:key, :string, []}

  schema "increments" do
    field :value, :integer
  end

  @doc false
  def changeset(increment, attrs) do
    increment
    |> cast(attrs, [:key, :value])
    |> validate_required([:key, :value])
    |> unique_constraint([:key])
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

  def from_list(values) do
    values
    |> Enum.map(fn {k, v} -> %{key: k, value: v} end)
  end
end
