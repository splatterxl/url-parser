defmodule Firefly do
  @spec request(String.t()) :: nil

  def request(url) do
    _ = URI.parse(url)

    nil
  end
end
