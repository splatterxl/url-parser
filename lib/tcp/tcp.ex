defmodule Firefly.Tcp do
  def send_request(url, method) when is_binary(url) and is_binary(method) do
    do_request(url, method)
  end

  defp do_request(url, method) do
    {:error, "not implemented"}
  end
end
