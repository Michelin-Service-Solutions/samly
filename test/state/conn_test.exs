defmodule Samly.State.ConnTest do
  use ExUnit.Case
  use Plug.Test

  alias Samly.Assertion
  alias Samly.State.Conn, as: ConnState

  setup do
    conn =
      conn(:get, "/")
    {:ok, conn: conn}
  end

  test "init is nil" do
    assert ConnState.init() == nil
  end

  test "put assertion", %{conn: conn} do
    conn =
      conn
      |> init_test_session(%{})
      |> ConnState.put({"test_assertion", "foo@example.com"}, %Assertion{})
    assert {"foo@example.com", %Assertion{}} == ConnState.get(conn, "test_assertion")
  end

  test "delete assertion", %{conn: conn} do
    conn =
      conn
      |> init_test_session(%{"test_assertion" => %Assertion{}})
      |> ConnState.delete("test_assertion")

    assert nil == get_session(conn, "test_assertion")
  end
end
