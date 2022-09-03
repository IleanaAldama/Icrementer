defmodule IncrementerTest do
  use ExUnit.Case

  describe "increment module" do
    test "should increment a new key and value" do
      assert Incrementer.increment("key", 2.0) == :ok
      assert Incrementer.lookup("key") == 2.0
    end

    test "should increment an exisiteing key" do
      assert Incrementer.increment("key2", 2.0) == :ok
      assert Incrementer.increment("key2", 6.0) == :ok
      assert Incrementer.lookup("key2") == 8.0
    end

    test "should return 0 if key is not found" do
      assert Incrementer.lookup("key3") == 0
    end
  end
end
