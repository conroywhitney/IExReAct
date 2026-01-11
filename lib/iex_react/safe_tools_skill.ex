defmodule IExReAct.SafeToolsSkill do
  @moduledoc """
  Safe tools for the IExReAct agent - vault-only file access and allowlisted URLs.
  """

  @vault_dir "vault"

  def vault_dir, do: @vault_dir

  @doc """
  Validates a path is safe (no escapes from vault).
  Raises ArgumentError if path attempts to escape.
  """

  def safe_path!(path) when is_binary(path) do
    if String.contains?(path, "..") or String.starts_with?(path, "/") do
      raise ArgumentError, "Path escape attempt blocked: #{path}"
    end

    Path.join(@vault_dir, path)
  end

  @doc """
  Reads a file from the vault directory.
  """
  def read_file(path) do
    safe_path!(path)
    |> File.read()
  end

  @doc """
  Writes content to a file in the vault directory.
  Creates parent directories if needed.
  """
  def write_file(path, content) do
    full_path = safe_path!(path)
    full_path |> Path.dirname() |> File.mkdir_p!()
    File.write!(full_path, content)
    :ok
  end

  @doc """
  Lists files in the vault directory matching a glob pattern.
  Returns paths relative to vault.
  """
  def list_files(pattern) do
    Path.join(@vault_dir, pattern)
    |> Path.wildcard()
    |> Enum.filter(&File.regular?/1)
    |> Enum.map(&String.replace_prefix(&1, "#{@vault_dir}/", ""))
  end

  @allowed_domains ~w[github.com raw.githubusercontent.com hexdocs.pm elixirforum.com]

  @doc """
  Fetches content from a URL, restricted to allowlisted domains.
  """
  def fetch_url(url) do
    uri = URI.parse(url)

    if uri.host in @allowed_domains do
      Req.get(url)
      |> case do
        {:ok, %{status: 200, body: body}} -> {:ok, body}
        {:ok, %{status: status}} -> {:error, "HTTP #{status}"}
        {:error, reason} -> {:error, "Request failed: #{inspect(reason)}"}
      end
    else
      {:error, "Domain not allowed: #{uri.host}"}
    end
  end
end
