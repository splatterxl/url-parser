defmodule Firefly.Url do
  def is_valid?(url) when is_binary(url) do
    components = get_components(url)
  end

  def get_components(url) when is_binary(url) do
    [protocol | rest] = String.split(url, "//")
    [domain | rest] = String.split(rest |> Enum.join("//"), "/")

    %{
      protocol: protocol,
      domain: domain,
      path: ["" | rest] |> Enum.join("/")
    }
  end
end
