defmodule Samly.State.EtsTest do
  use ExUnit.Case
  use Plug.Test

  alias Samly.Assertion
  alias Samly.State.Ets, as: EtsState

  setup do
    EtsState.init()
    {:ok, conn: conn(:get, "/")}
  end

  test "put assertion", %{conn: conn} do
    conn =
      conn
      |> init_test_session(%{})
      |> EtsState.put({"test_assertion", "foo@example.com"}, %Assertion{})

    assert {"foo@example.com", %Assertion{}} = EtsState.get(conn, "test_assertion")
  end

  test "delete assertion", %{conn: conn} do
    conn =
      conn
      |> init_test_session(%{})
      |> EtsState.put({"test_assertion", "foo@example.com"}, %Assertion{})
      |> EtsState.delete("test_assertion")

    assert nil == EtsState.get(conn, "test_assertion")
  end
end
