defmodule Firefly.Host do
  @moduledoc false

  def ip?(host) when is_binary(host) do
    ipv4?(host) or ipv6?(host)
  end

  def ipv4?(host) when is_binary(host) do
    host =~ ~r/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/
  end

  def ipv6?(host) when is_binary(host) do
    host =~ ~r/^[0-9a-f]{1,4}(:[0-9a-f]{1,4}){7}$/i
  end
end
