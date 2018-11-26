defmodule Samly.State.Ets do
  @behaviour Samly.State

  import Plug.Conn, only: [get_session: 2, put_session: 3, delete_session: 2]

  alias Samly.Assertion

  @impl true
  def init() do
    :ets.new(:esaml_nameids, [:set, :private, :named_table])
  end

  @impl true
  def get(conn, key) do
    table_key =
      conn
      |> get_session(key)

    case :ets.lookup(:esaml_nameids, table_key) do
      [{^table_key, %Assertion{}} = ret] ->
        ret

      _ ->
        nil
    end
  end

  @impl true
  def put(conn, {sess_key, key}, saml_assertion) do
    :ets.insert(:esaml_nameids, {key, saml_assertion})
    conn
    |> put_session(sess_key, key)
  end

  @impl true
  def delete(conn, key) do
    table_key =
      conn
      |> get_session(key)
    :ets.delete(:esaml_nameids, table_key)
    conn
    |> delete_session(key)
  end
end
