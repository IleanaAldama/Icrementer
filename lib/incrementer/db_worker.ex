defmodule Incrementer.DBWorker do
  alias Incrementer.{Repo, Increment}
  use GenServer

  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  def sync(values) do
    GenServer.cast(__MODULE__, {:sync_db, values})
  end

  @impl true
  def handle_cast({:sync_db, values}, [send_to: module] = state) do
    result =
      Repo.insert_all(Increment, Increment.from_list(values),
        on_conflict: :replace_all,
        conflict_target: :key
      )

    GenServer.cast(module, {:sync_db_done, result})
    {:noreply, state}
  end
end
