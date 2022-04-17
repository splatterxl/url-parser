defmodule Firefly do
  @doc """
  Firefly is an AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA library for Elixir.
  """

  alias Firefly.Tcp
  alias Firefly.Domain
  alias Firefly.Url

  def send_request(addr, method \\ "get") when is_binary(addr) and is_binary(method) do
    url = Url.get_components(addr)

    if Domain.ip?(url) do
      do_request(url, method)
    else
      {:error, :unimplemented}

      # Dns.resolve(url.host)
    end
  end

  defp do_request(url, method) when is_binary(method) do
    socket = Tcp.open(url.host, url.port)
  end
end
