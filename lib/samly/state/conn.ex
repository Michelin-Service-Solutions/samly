defmodule Samly.State.Conn do
  @moduledoc """
  Implementation of the state behaviour that stores the SAML assertion directly in the `Plug.Conn.Session`. This allows the assertion state to be
  shared with other application nodes in a stateless fashion.

  If the Plug.Conn.Session is cookie based, this will add to the size of the cookie header and should be monitored.
  """
  @behaviour Samly.State

  import Plug.Conn

  @impl true
  def init(), do: nil

  @impl true
  def get(conn, sess_key) do
    conn
    |> get_session(sess_key)
  end

  @impl true
  def put(conn, {sess_key, name_id}, assertion) do
    conn
    |> put_session(sess_key, {name_id, assertion})
  end

  @impl true
  def delete(conn, sess_key) do
    conn
    |> delete_session(sess_key)
  end
end
