defmodule Incrementer.DBWorker do
  alias Incrementer.{Repo, Increment}
  use GenServer
  require Logger

  @max_updates 100
  @polling_time 10_000

  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  @impl true
  def init(send_to: module) do
    schedule_sync()
    {:ok, %{send_to: module, queue: %{}, updates: 0}}
  end

  def enqueue(val) do
    GenServer.cast(__MODULE__, {:enqueue, val})
  end

  @impl true
  def handle_cast({:enqueue, {key, value}}, state) do
    queue = Map.put(state[:queue], key, value)
    updates = state[:updates] + 1

    state_delta =
      if updates > @max_updates do
        sync(state)
        %{queue: %{}, updates: 0}
      else
        %{queue: queue, updates: updates}
      end

    {:noreply, Map.merge(state, state_delta)}
  end

  @impl true
  def handle_info(:timeout, state) do
    sync(state)
    schedule_sync()
    {:noreply, Map.merge(state, %{queue: %{}, updates: 0})}
  end

  defp schedule_sync do
    Logger.info("Scheduling sync")
    Process.send_after(self(), :timeout, @polling_time)
  end

  defp sync(%{updates: 0}) do
    :noop
  end

  defp sync(%{queue: values, send_to: module}) do
    values =
      values
      |> Map.to_list()
      |> Enum.map(fn {k, v} -> %{key: k, value: v} end)

    result =
      Repo.insert_all(Increment, values,
        on_conflict: :replace_all,
        conflict_target: :key
      )

    GenServer.cast(module, {:sync_db_done, result})
    result
  end
end
