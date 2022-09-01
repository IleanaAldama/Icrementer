defmodule Incrementer.IncrementTest do
  use ExUnit.Case
  alias Incrementer.Increment

  describe "increment module" do
    test "should increment a new key and value" do
      assert Increment.increment(:key, 2) == true
      assert Increment.lookup(:key) == 2
    end

    test "should increment an exisiteing key" do
      assert Increment.increment(:key2, 2) == true
      assert Increment.increment(:key2, 6) == true
      assert Increment.lookup(:key2) == 8
    end

    test "should return 0 if key is not found" do
      assert Increment.lookup(:key3) == 0
    end
  end
end
