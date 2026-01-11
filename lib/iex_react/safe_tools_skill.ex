defmodule IExReAct.SafeToolsSkill do
  @moduledoc """
  Safe tools for the IExReAct agent - vault-only file access and allowlisted URLs.
  """

  @doc """
  Validates a path is safe (no escapes from vault).
  Raises ArgumentError if path attempts to escape.
  """
  @vault_dir "vault"

  def safe_path!(path) when is_binary(path) do
    if String.contains?(path, "..") or String.starts_with?(path, "/") do
      raise ArgumentError, "Path escape attempt blocked: #{path}"
    end

    Path.join(@vault_dir, path)
  end
end
