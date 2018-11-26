defmodule SamlyTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Samly.{Assertion, State}

  setup do
    conn =
      conn(:get, "/")
      |> init_test_session(%{"samly_assertion" => {'test@example.com', %Assertion{}}})
    {:ok, conn: conn}
  end

  test "get active assertion returns assertion in sesssion", %{conn: conn} do
    assert %Assertion{} == Samly.get_active_assertion(conn, State.Conn)
  end

  test "get active assertion is nil when no assertion in session", %{conn: conn} do
    conn =
      conn
      |> delete_session("samly_assertion")
    refute Samly.get_active_assertion(conn, State.Conn)
  end
end
