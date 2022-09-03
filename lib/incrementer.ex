defmodule Incrementer do
  @moduledoc """
  Incrementer keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Incrementer.{DBWorker, Repo}
  use GenServer
  require Logger
  @table :increment_table

  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    init_ets()
    {:ok, [sync_needed: false]}
  end

  def increment(key, value) do
    GenServer.cast(__MODULE__, {:increment, key, value})
    :ok
  end

  def lookup(key) do
    GenServer.call(__MODULE__, {:lookup, key})
  end

  @impl true
  def handle_call({:lookup, key}, _from, state) do
    {:reply, value(key), state}
  end

  @impl true
  def handle_cast({:increment, key, value}, state) do
    new_value = value(key) + value

    :ets.insert(@table, {key, new_value})
    DBWorker.enqueue({key, new_value})

    {:noreply, state}
  end

  @impl true
  def handle_cast({:sync_db_done, result}, state) do
    Logger.info("Sync done", result: inspect(result))
    {:noreply, state}
  end

  defp value(key) do
    case :ets.lookup(@table, key) do
      [] -> 0
      [{_key, value}] -> value
    end
  end

  defp init_ets do
    :ets.new(@table, [:set, :private, :named_table])

    objects =
      Incrementer.Increment
      |> Repo.all()
      |> Enum.map(fn %{key: k, value: v} -> {k, v} end)

    :ets.insert(@table, objects)
  end
end
