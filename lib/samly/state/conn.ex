defmodule Samly.State.Conn do
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
