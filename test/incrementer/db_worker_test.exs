defmodule Incrementer.DBWorkerTest do
  use ExUnit.Case
  alias Incrementer.DBWorker
  alias Incrementer.Repo

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    # Setting the shared mode must be done only after checkout
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    DBWorker.register_callback(self())
  end

  describe "Db Worker" do
    test "it should enque and sync changes" do
      DBWorker.enqueue({"key", 20.1})
      DBWorker.enqueue({"key2", 12.0})

      assert %{queue: %{"key" => 20.1, "key2" => 12.0}} = :sys.get_state(DBWorker)
      assert_receive {_, {:sync_db_done, _}}, 1000
    end
  end
end
