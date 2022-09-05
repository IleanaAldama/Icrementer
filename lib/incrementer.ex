defmodule Incrementer do
  @moduledoc """
  Incrementer implements a {key, value} storage/incremet making sure changes are equeue for
  persistant storage in a database
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

  @doc """
   Increase the previously stored number associated with the key by the value ammount.
   If the key is not found will be set equals to value.

  ## Examples

    iex> Incrementer.increment("key", 2) #Sets "key" as 2
    :ok
  """
  @spec increment(key :: String.t(), value :: number) :: :ok
  def increment(key, value) do
    GenServer.cast(__MODULE__, {:increment, key, value})
    :ok
  end

  @doc """
    Returns the value associated with the key, if value is not found 0 is returned instead.

  ## Examples

    iex> Incrementer.lookup("key")
    2
  """
  @spec lookup(key :: String.t()) :: number
  def lookup(key) do
    GenServer.call(__MODULE__, {:lookup, key})
  end

  @impl true
  def handle_call({:lookup, key}, _from, state) do
    {:reply, value(key), state}
  end

  @impl true
  def handle_cast({:increment, key, value}, state) do
    new_value = :ets.update_counter(@table, key, value, {key, 0})
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
