defmodule Incrementer.DBWorker do
  @moduledoc """
  DBWorker enqueues and persits in a postgres database changes in the k,v storage
  It can be configured specifyng the max number changes, callback module and polling time:

  After the sync is done a message of {:db_sync_done, result} will be sent to the callback module

  config :incrementer, Incrementer.DBWorker,
    max_updates: 1000,
    polling_time: 5_000,
    send_to: MyCallbackModule
  """
  alias Incrementer.{Repo, Increment}
  use GenServer
  require Logger
  @table :delta_table

  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  @impl true
  def init(options) do
    config =
      :incrementer
      |> Application.get_env(__MODULE__)
      |> Keyword.merge(options)

    :ets.new(@table, [:set, :private, :named_table])
    schedule_sync(config[:polling_time])

    {:ok,
     %{
       send_to: config[:send_to],
       updates: 0,
       polling_time: config[:polling_time],
       max_updates: config[:max_updates]
     }}
  end

  @doc """
  Add a new change to the sync queue, value most be a tuple of the form {key, value}
  """
  @spec enqueue({String.t(), number}) :: term()
  def enqueue(val) do
    GenServer.cast(__MODULE__, {:enqueue, val})
  end

  @doc """
  Changes the callback module at runtime
  """
  @spec register_callback(pid()) :: term()
  def register_callback(pid) do
    GenServer.cast(__MODULE__, {:callback, pid})
  end

  @impl true
  def handle_cast({:callback, pid}, state) do
    {:noreply, Map.put(state, :send_to, pid)}
  end

  @impl true
  def handle_cast({:enqueue, {key, value}}, state) do
    :ets.insert(@table, {key, value})
    updates = state[:updates] + 1

    state_delta =
      if updates > state[:max_updates] do
        sync(state)
        %{updates: 0}
      else
        %{updates: updates}
      end

    {:noreply, Map.merge(state, state_delta)}
  end

  @impl true
  def handle_info(:timeout, state) do
    sync(state)
    schedule_sync(state[:polling_time])
    {:noreply, Map.merge(state, %{updates: 0})}
  end

  defp schedule_sync(timeout) do
    Logger.info("Scheduling sync")
    Process.send_after(self(), :timeout, timeout)
  end

  defp sync(%{updates: 0}) do
    :noop
  end

  defp sync(%{send_to: module}) do
    values =
      @table
      |> :ets.tab2list()
      |> Enum.map(fn {k, v} -> %{key: k, value: v} end)

    result =
      Repo.insert_all(Increment, values,
        on_conflict: :replace_all,
        conflict_target: :key
      )

    :ets.delete_all_objects(@table)
    GenServer.cast(module, {:sync_db_done, result})
    result
  end
end
