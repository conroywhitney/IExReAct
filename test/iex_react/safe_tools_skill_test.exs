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
end
