defmodule Samly.SPHandlerTest do
  use ExUnit.Case
  use Plug.Test

  import Samly.Esaml, only: [esaml_sp: 2]

  alias Samly.{Assertion, IdpData, SPHandler, SpData, State}

  defmodule TestConn do
    use Plug.Builder

    plug Plug.Parsers,
      parsers: [:urlencoded]
  end

  setup do
    idp_config =
      IdpData.load_provider(
        %{
          id: "test_idp",
          sp_id: "test_sp",
          base_url: "http://localhost:8080/sso",
          sign_requests: false,
          sign_metadata: false,
          signed_assertion_in_resp: false,
          signed_envelopes_in_resp: false,
          metadata_file: "test/data/idp_metadata.xml"
        },
        %{"test_sp" => SpData.load_provider(%{id: "test_sp"})}
    )
    {:ok, idp_config: %{idp_config | esaml_sp_rec: esaml_sp(idp_config.esaml_sp_rec, idp_signs_logout_requests: false)}}
  end

  test "send metadata", %{idp_config: idp_data} do
    conn =
      conn(:get, "/")
      |> put_private(:samly_idp, idp_data)
      |> SPHandler.send_metadata()

    assert conn.status == 200
    assert ["text/xml"] = get_resp_header(conn, "content-type")
  end

  describe "signin handling" do
    setup do
      conn =
        conn(:post, "/", %{
          "SAMLResponse" => File.read!("test/data/auth_response.xml") |> Base.encode64(),
          "RelayState" => "93YkxPcU2Dhlnz8JGiBWuu7UPkOA8syc"
        })
        |> TestConn.call([])
        |> init_test_session(%{
            "idp_id" => "test_idp",
            "relay_state" => "93YkxPcU2Dhlnz8JGiBWuu7UPkOA8syc",
            "target_url" => "https://example.com/foo"
          })
      {:ok, conn: conn}
    end

    test "invalid response", %{conn: conn} do
      conn =
        conn
        |> put_private(:samly_idp, %IdpData{})
        |> SPHandler.consume_signin_response(State.Conn)

      assert conn.status == 403
    end

    test "valid response", %{conn: conn, idp_config: idp_data} do
      conn =
        conn
        |> put_private(:samly_idp, idp_data)
        |> SPHandler.consume_signin_response(State.Conn)

      assert conn.status == 302
      ["https://example.com/foo"] = get_resp_header(conn, "location")
    end
  end

  describe "logout request" do
    setup do
      conn =
        conn(:post, "/", %{
          "SAMLRequest" => File.read!("test/data/logout_request.xml") |> Base.encode64(),
          "RelayState" => "93YkxPcU2Dhlnz8JGiBWuu7UPkOA8syc"
        })
        |> TestConn.call([])
      {:ok, conn: conn}
    end

    test "invalid", %{conn: conn, idp_config: idp_data} do
      conn =
        conn
        |> put_private(:samly_idp, idp_data)
        |> init_test_session(%{"samly_assertion" => {'test@example.com', nil}})
        |> SPHandler.handle_logout_request(State.Conn)

      refute get_session(conn, "samly_assertion")
      assert conn.status == 200
    end

    test "valid", %{conn: conn, idp_config: idp_data} do
      conn =
        conn
        |> put_private(:samly_idp, idp_data)
        |> init_test_session(%{"samly_assertion" => {'test@example.com', %Assertion{idp_id: "test_idp"}}})
        |> SPHandler.handle_logout_request(State.Conn)

      refute get_session(conn, "samly_assertion")
      assert conn.status == 200
    end
  end

  describe "logout response" do
    setup do
      relay_state = "93YkxPcU2Dhlnz8JGiBWuu7UPkOA8syc"
      conn =
        conn(:post, "/", %{
          "SAMLResponse" => File.read!("test/data/logout_response.xml") |> Base.encode64(),
          "RelayState" => relay_state
        })
        |> TestConn.call([])
        |> init_test_session(%{"idp_id" => "test_idp", "relay_state" => relay_state, "target_url" => "http://example.com/foo"})
      {:ok, conn: conn}
    end

    test "invalid", %{conn: conn, idp_config: idp_data} do
      conn =
        conn
        |> put_private(:samly_idp, idp_data)
        |> delete_session("relay_state")
        |> SPHandler.handle_logout_response()

      assert conn.status == 403
    end

    test "valid", %{conn: conn, idp_config: idp_data} do
      conn =
        conn
        |> put_private(:samly_idp, idp_data)
        |> SPHandler.handle_logout_response()

      assert conn.status == 302
      assert ["http://example.com/foo"] = get_resp_header(conn, "location")
    end
  end
end
