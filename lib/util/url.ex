defmodule Firefly.Url do
  @moduledoc """
  This module provides a simple interface to the URL parsing and 
  manipulation functions, conformant to RFC 1738.
  """

  def is_valid?(url) when is_binary(url) do
    components = get_components(url)

    case components do
      {:error, _} -> false
      {:ok, _} -> true
    end
  end

  def get_path_string(url) when is_binary(url) do
    components = get_components(url)

    case components do
      {:error, _} -> nil
      {:ok, components} -> "#{components.path}?#{components.query}##{components.fragment}"
    end
  end

  def get_components(url) when is_binary(url) do
    if not String.valid?(url) do
      {:error, :invalid_string}
    else
      [protocol | rest] = String.split(url, ":")

      if length(rest) == 0 do
        {:error, :invalid_url}
      else
        get_components_for_protocol(protocol, Enum.join(rest, ":"))
      end
    end
  end

  defp get_components_for_protocol(protocol, rest) when is_binary(protocol) and is_binary(rest) do
    case String.downcase(protocol) do
      "http" -> get_http_components(rest)
      "https" -> get_http_components(rest, "https")
      "ftp" -> get_ftp_components(rest)
      _ -> {:error, :unrecognised_protocol}
    end
  end

  defp get_http_components(rest, protocol \\ "http")
       when is_binary(rest) and is_binary(protocol) do
    if not String.starts_with?(rest, "//") do
      {:error, :invalid_url}
    else
      [rest | tail] = String.split(rest, "//", trim: true)
      # account for double slash
      rest = [rest | tail] |> Enum.join("//")

      {login, rest} = get_login(rest)
      {port, rest} = get_port(rest, protocol)

      if port == -1 do
        {:error, :invalid_port}
      else
        {host, rest} = get_host(rest)
        {fragment, rest} = get_fragment(rest)
        {query, rest} = get_query(rest)
        {path, _} = get_path(rest)

        {:ok,
         %{
           scheme: protocol,
           login: login,
           port: port,
           fragment: fragment,
           query: query,
           path: path,
           host: host
         }}
      end
    end
  end

  defp get_ftp_components(rest) when is_binary(rest) do
    if not String.starts_with?(rest, "//") do
      {:error, :invalid_url}
    else
      [rest | tail] = String.split(rest, "//", trim: true)
      # account for double slash
      rest = [rest | tail] |> Enum.join("//")

      {login, rest} = get_login(rest)

      {port, rest} = get_port(rest, "ftp")

      if port == -1 do
        {:error, :invalid_port}
      else
        {host, rest} = get_host(rest)
        {typecode, rest} = get_typecode(rest)

        if typecode == :error do
          {:error, rest}
        else
          {path, _} = get_path(rest)

          {:ok,
           %{
             scheme: "ftp",
             login: login,
             port: port,
             path: path,
             host: host,
             typecode: typecode
           }}
        end
      end
    end
  end

  defp get_login(rest) when is_binary(rest) do
    if String.contains?(rest, "@") do
      [user | rest] = String.split(rest, "@")

      if String.contains?(user, ":") do
        login = String.split(user, ":")

        if length(login) > 2 do
          {nil, rest |> Enum.join(":")}
        else
          [user, password] = login

          {
            %{
              user: user,
              password: password
            },
            rest |> Enum.join("@")
          }
        end
      else
        {
          %{
            user: user,
            password: nil
          },
          rest |> Enum.join("@")
        }
      end
    else
      {nil, rest}
    end
  end

  defp default_http_port() do
    80
  end

  defp default_https_port() do
    443
  end

  defp get_port(rest, protocol) when is_binary(rest) and is_binary(protocol) do
    if String.contains?(rest, ":") do
      list = String.split(rest, ":")

      if length(list) > 2 do
        {:error, :invalid_port}
      else
        [rest, port] = list
        [port | path] = String.split(port, "/")
        rest = [rest | path] |> Enum.join("/")

        {String.to_integer(port), rest}
      end
    else
      case protocol do
        "http" -> {default_http_port(), rest}
        "https" -> {default_https_port(), rest}
        _ -> {-1, rest}
      end
    end
  end

  defp get_fragment(rest) when is_binary(rest) do
    if String.contains?(rest, "#") do
      list = String.split(rest, "#")

      if length(list) > 2 do
        {:error, :invalid_url}
      else
        [rest, fragment] = list

        {fragment, rest}
      end
    else
      {nil, rest}
    end
  end

  defp get_query(rest) when is_binary(rest) do
    if String.contains?(rest, "?") do
      [eligible | tail] = String.split(rest, "/") |> Enum.reverse()
      list = String.split(eligible, "?")

      rest = ["" | Enum.reverse([eligible | tail])]

      if length(list) > 2 do
        {:error, :invalid_url}
      else
        [append, query] = list

        rest = [rest | [append]] |> Enum.join("/")

        {query, rest}
      end
    else
      {nil, rest}
    end
  end

  defp get_path(rest) when is_binary(rest) do
    if String.contains?(rest, "/") do
      [rest | path] = String.split(rest, "/")

      {"/" <> (path |> Enum.join("/")), rest}
    else
      {nil, rest}
    end
  end

  defp get_host(rest) when is_binary(rest) do
    if String.contains?(rest, "/") do
      [host | rest] = String.split(rest, "/")
      # re-add slash consumed by above
      rest = ["" | rest]
      {host, rest |> Enum.join("/")}
    else
      {rest, ""}
    end
  end

  defp get_typecode(rest) when is_binary(rest) do
    if String.contains?(rest, ";type=") do
      list = String.split(rest, "/") |> Enum.reverse()
      [hd | tail] = list

      [first | next] = String.split(hd, ";type=")
      [code | aaaa] = next

      if length(aaaa) != 0 or String.length(code) > 1 do
        {:error, :invalid_typecode}
      else
        rest = [tail |> Enum.reverse() |> Enum.join("/") | [first]]

        {code, rest |> Enum.join("/")}
      end
    else
      {nil, rest}
    end
  end
end
