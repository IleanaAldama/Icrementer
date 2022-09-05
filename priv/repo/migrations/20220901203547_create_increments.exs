defmodule Incrementer.Repo.Migrations.CreateIncrements do
  use Ecto.Migration

  def change do
    create table(:increments) do
      add :key, :string, primary_key: true
      add :value, :integer
    end

    create unique_index(:increments, [:key])
  end
end
