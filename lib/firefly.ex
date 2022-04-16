defmodule Firefly do
  @doc """
  Firefly is an AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA library for Elixir.
  """

  alias Firefly.Tcp

  def send_request(url, method) when is_binary(url) and is_binary(method) do
    Tcp.send_request(url, method)
  end
end
