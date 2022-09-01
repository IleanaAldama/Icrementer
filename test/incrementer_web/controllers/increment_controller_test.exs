defmodule IncrementerWeb.IncrementControllerTest do
  use IncrementerWeb.ConnCase

  describe "Incrment Contoller" do
    test "should increment a new key", %{conn: conn} do
      conn =
        post(conn, Routes.increment_path(conn, :increment), %{"key" => "some_key", "value" => 2})

      assert response(conn, 202) == ""
      assert Incrementer.lookup("some_key") == 2
    end

    test "should increment a existing key", %{conn: conn} do
      Incrementer.increment("some_key2", 4)

      conn =
        post(conn, Routes.increment_path(conn, :increment), %{"key" => "some_key2", "value" => 2})

      assert response(conn, 202) == ""
      assert Incrementer.lookup("some_key2") == 6
    end
  end

  describe "Error handling" do
    test "should return 400 if params not present", %{conn: conn} do
      conn = post(conn, Routes.increment_path(conn, :increment), %{})
      assert %{"errors" => [_err1, _err2]} = json_response(conn, 400)
    end

    test "should return 400 if value is not a number", %{conn: conn} do
      conn =
        post(conn, Routes.increment_path(conn, :increment), %{
          "key" => "some_key",
          "value" => "abc"
        })

      assert %{"errors" => [_err]} = json_response(conn, 400)
    end
  end
end
