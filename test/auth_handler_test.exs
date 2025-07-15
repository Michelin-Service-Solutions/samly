defmodule Samly.AuthHandlerTest do
  use ExUnit.Case
  use Plug.Test

  alias Samly.{Assertion, AuthHandler, IdpData, SpData, State}

  setup do
    idp_config =
      IdpData.load_provider(
        %{
          id: "test_idp",
          sp_id: "test_sp",
          base_url: "http://localhost:8080/foo",
          sign_requests: false,
          sign_metadata: false,
          signed_assertion_in_resp: false,
          signed_envelopes_in_resp: false,
          metadata_file: "test/data/idp_metadata.xml"
        },
        %{"test_sp" => SpData.load_provider(%{id: "test_sp"})}
      )

    conn =
      conn(:get, "/?target_url=https://example.com/foo")
      |> init_test_session(%{})

    {:ok, conn: conn, idp_config: idp_config}
  end

  test "initiate sso req", %{conn: conn} do
    conn = AuthHandler.initiate_sso_req(conn)
    assert conn.status == 200
  end

  test "send signin req redirect to target", %{conn: conn, idp_config: idp_data} do
    conn =
      conn
      |> fetch_query_params()
      |> put_private(:samly_idp, idp_data)
      |> put_session("samly_assertion", {"test@example.com", %Assertion{idp_id: "test_idp"}})
      |> AuthHandler.send_signin_req(State.Conn)

    assert conn.status == 302
    assert [location | _] = get_resp_header(conn, "location")
    assert location == "https://example.com/foo"
  end

  test "send signin req", %{conn: conn, idp_config: idp_data} do
    conn =
      conn
      |> fetch_query_params()
      |> put_private(:samly_idp, idp_data)
      |> AuthHandler.send_signin_req(State.Conn)

    assert get_session(conn, "relay_state")
    assert get_session(conn, "idp_id") == "test_idp"
    assert get_session(conn, "target_url") == "https://example.com/foo"
  end

  test "unauthorized signout request", %{conn: conn, idp_config: idp_data} do
    conn =
      conn
      |> fetch_query_params()
      |> put_private(:samly_idp, idp_data)
      |> AuthHandler.send_signout_req(State.Conn)

    assert conn.status == 403
  end

  test "signout request", %{conn: conn, idp_config: idp_data} do
    conn =
      conn
      |> fetch_query_params()
      |> put_private(:samly_idp, idp_data)
      |> put_session("samly_assertion", {"test@example.com", %Assertion{idp_id: "test_idp"}})
      |> AuthHandler.send_signout_req(State.Conn)

    refute get_session(conn, "samly_assertion")
    assert ["text/html"] = get_resp_header(conn, "content-type")
    assert conn.status == 200
  end
end
