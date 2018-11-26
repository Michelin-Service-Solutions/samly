defmodule Samly.State do
  @moduledoc """
  This behaviour defines the interface for accessing, updating and deleting the saml assertion for the given nameid
  """

  alias Plug.Conn
  alias Samly.Assertion

  @type session_key :: binary()
  @type name_id :: binary()
  @type assertion_key :: {session_key(), name_id()}

  @callback init() :: no_return()

  @callback get(Conn.t(), session_key()) :: {name_id(), Assertion.t()}

  @callback put(Conn.t(), assertion_key(), Assertion.t()) :: Conn.t()

  @callback delete(Conn.t(), session_key()) :: Conn.t()

  def gen_id() do
    24
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
  end
end
