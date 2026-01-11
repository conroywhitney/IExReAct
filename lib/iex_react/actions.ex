defmodule IExReAct.Actions do
  @moduledoc """
  Jido Actions wrapping SafeToolsSkill functions for agent tool use.
  """

  alias Jido.Action
  alias IExReAct.SafeToolsSkill

  defmodule ReadFile do
    use Action,
      name: "read_file",
      description: "Reads a file from the vault directory",
      schema: [
        path: [type: :string, required: true, doc: "Path relative to vault (e.g., 'notes/idea.md')"]
      ]

    def run(%{path: path}, _context) do
      case SafeToolsSkill.read_file(path) do
        {:ok, content} -> {:ok, %{content: content}}
        {:error, reason} -> {:error, inspect(reason)}
      end
    rescue
      e in ArgumentError -> {:error, e.message}
    end
  end

  defmodule WriteFile do
    use Action,
      name: "write_file",
      description: "Writes content to a file in the vault directory",
      schema: [
        path: [type: :string, required: true, doc: "Path relative to vault"],
        content: [type: :string, required: true, doc: "Content to write"]
      ]

    def run(%{path: path, content: content}, _context) do
      SafeToolsSkill.write_file(path, content)
      {:ok, %{status: "File written successfully to #{path}"}}
    rescue
      e in ArgumentError -> {:error, e.message}
    end
  end

  defmodule ListFiles do
    use Action,
      name: "list_files",
      description: "Lists files in the vault matching a glob pattern",
      schema: [
        pattern: [type: :string, required: true, doc: "Glob pattern (e.g., '**/*.md' or 'notes/*.txt')"]
      ]

    def run(%{pattern: pattern}, _context) do
      files = SafeToolsSkill.list_files(pattern)
      {:ok, %{files: files}}
    end
  end

  defmodule FetchUrl do
    use Action,
      name: "fetch_url",
      description: "Fetches content from an allowlisted URL (github.com, hexdocs.pm, etc.)",
      schema: [
        url: [type: :string, required: true, doc: "URL to fetch (must be from allowlisted domain)"]
      ]

    def run(%{url: url}, _context) do
      case SafeToolsSkill.fetch_url(url) do
        {:ok, body} -> {:ok, %{content: body}}
        {:error, reason} -> {:error, reason}
      end
    end
  end

  def all, do: [ReadFile, WriteFile, ListFiles, FetchUrl]
end
