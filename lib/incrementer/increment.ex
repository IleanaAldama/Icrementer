defmodule Incrementer.Increment do
  use GenServer
  @table :increment_table

  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    :ets.new(@table, [:set, :private, :named_table])
    {:ok, @table}
  end

  def increment(key, value) do
    GenServer.call(__MODULE__, {:increment, key, value})
  end

  def lookup(key) do
    GenServer.call(__MODULE__, {:lookup, key})
  end

  @impl true
  def handle_call({:lookup, key}, _from, state) do
    {:reply, value(key), state}
  end

  @impl true
  def handle_call({:increment, key, value}, _from, state) do
    new_value = value(key) + value

    response =
      if :ets.insert(@table, {key, new_value}), do: :ok, else: {:error, "failed to increment"}

    {:reply, response, state}
  end

  defp value(key) do
    case :ets.lookup(@table, key) do
      [] -> 0
      [{_key, value}] -> value
    end
  end
end
