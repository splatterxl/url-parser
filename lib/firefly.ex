defmodule Firefly do
  @doc """
  Firefly is an AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA library for Elixir.
  """

  alias Firefly.Tcp
  alias Firefly.Domain
  alias Firefly.Url

  def send_request(addr, method \\ "get") when is_binary(addr) and is_binary(method) do
    {status, url} = Url.get_components(addr)
    if status == :ok do
      if Domain.ip?(url.host) do
        do_request(url, method)
      else
        {:error, :unimplemented}

        # Dns.resolve(url.host)
      end
    else
      {:error, url}
    end
  end

  defp do_request(url, method) when is_binary(method) do
    socket = Tcp.open(url.host, url.port)
  end
end
