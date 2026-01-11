defmodule IExReAct.SafeToolsSkillTest do
  use ExUnit.Case, async: true

  alias IExReAct.SafeToolsSkill

  describe "safe_path!/1" do
    test "blocks path traversal with ../" do
      assert_raise ArgumentError, ~r/Path escape/, fn ->
        SafeToolsSkill.safe_path!("../etc/passwd")
      end
    end

    test "blocks absolute paths" do
      assert_raise ArgumentError, ~r/Path escape/, fn ->
        SafeToolsSkill.safe_path!("/etc/passwd")
      end
    end

    test "returns full vault path for valid relative paths" do
      assert SafeToolsSkill.safe_path!("notes/idea.md") == "vault/notes/idea.md"
    end
  end

  describe "read_file/1" do
    setup do
      # Create test file in vault
      File.mkdir_p!("vault/test")
      File.write!("vault/test/sample.txt", "Hello from vault!")
      on_exit(fn -> File.rm_rf!("vault/test") end)
      :ok
    end

    test "reads file from vault" do
      assert {:ok, "Hello from vault!"} = SafeToolsSkill.read_file("test/sample.txt")
    end
  end

  describe "write_file/2" do
    setup do
      on_exit(fn -> File.rm_rf!("vault/write_test") end)
      :ok
    end

    test "writes file to vault with parent directory creation" do
      assert :ok = SafeToolsSkill.write_file("write_test/nested/file.txt", "New content")
      assert File.read!("vault/write_test/nested/file.txt") == "New content"
    end
  end

  describe "list_files/1" do
    setup do
      File.mkdir_p!("vault/notes")
      File.write!("vault/notes/one.md", "one")
      File.write!("vault/notes/two.md", "two")
      File.write!("vault/notes/other.txt", "other")
      on_exit(fn -> File.rm_rf!("vault/notes") end)
      :ok
    end

    test "lists files matching glob pattern" do
      files = SafeToolsSkill.list_files("notes/*.md")
      assert Enum.sort(files) == ["notes/one.md", "notes/two.md"]
    end
  end

  describe "fetch_url/1" do
    test "blocks non-allowlisted domains" do
      assert {:error, "Domain not allowed: evil.com"} =
               SafeToolsSkill.fetch_url("https://evil.com/malware")
    end
  end
end
