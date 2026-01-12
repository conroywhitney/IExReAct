defmodule IExReAct.LoggerFilterTest do
  use ExUnit.Case, async: true

  alias IExReAct.LoggerFilter

  describe "filter/2 with string messages" do
    test "redacts Anthropic API keys" do
      event = %{msg: {:string, "Key: sk-ant-api03-abc123def456ghi789jkl012mno345pqr678stu901vwx234yz"}}

      result = LoggerFilter.filter(event, [])

      assert %{msg: {:string, redacted}} = result
      assert redacted == "Key: [REDACTED_ANTHROPIC_KEY]"
    end

    test "redacts OpenAI API keys" do
      event = %{msg: {:string, "Key: sk-abcdefghijklmnopqrstuvwxyz123456789"}}

      result = LoggerFilter.filter(event, [])

      assert %{msg: {:string, redacted}} = result
      assert redacted == "Key: [REDACTED_OPENAI_KEY]"
    end

    test "redacts api_key field pattern in inspect output" do
      event = %{msg: {:string, ~s(Model: %{api_key: "secret-key-here", model: "gpt-4"})}}

      result = LoggerFilter.filter(event, [])

      assert %{msg: {:string, redacted}} = result
      assert redacted =~ ~s(api_key: "[REDACTED]")
      assert redacted =~ ~s(model: "gpt-4")
    end

    test "passes through non-sensitive strings unchanged" do
      event = %{msg: {:string, "Normal log message without secrets"}}

      result = LoggerFilter.filter(event, [])

      assert %{msg: {:string, "Normal log message without secrets"}} = result
    end
  end

  describe "filter/2 with report messages" do
    test "redacts api_key in map reports" do
      event = %{msg: {:report, %{api_key: "sk-secret", other: "value"}}}

      result = LoggerFilter.filter(event, [])

      assert %{msg: {:report, %{api_key: "[REDACTED]", other: "value"}}} = result
    end

    test "redacts anthropic_api_key in map reports" do
      event = %{msg: {:report, %{anthropic_api_key: "sk-ant-api03-secret", other: "value"}}}

      result = LoggerFilter.filter(event, [])

      assert %{msg: {:report, %{anthropic_api_key: "[REDACTED]", other: "value"}}} = result
    end

    test "recursively redacts nested maps" do
      event = %{msg: {:report, %{config: %{api_key: "secret"}, name: "test"}}}

      result = LoggerFilter.filter(event, [])

      assert %{msg: {:report, %{config: %{api_key: "[REDACTED]"}, name: "test"}}} = result
    end
  end

  describe "filter/2 with format messages" do
    test "redacts API keys in format arguments" do
      event = %{msg: {"Params: ~p", [%{api_key: "sk-secret"}]}}

      result = LoggerFilter.filter(event, [])

      assert %{msg: {"Params: ~p", [%{api_key: "[REDACTED]"}]}} = result
    end

    test "redacts strings in format arguments" do
      event = %{msg: {"Key is ~s", ["sk-ant-api03-abc123def456ghi789jkl012mno345pqr678stu901vwx234yz"]}}

      result = LoggerFilter.filter(event, [])

      assert %{msg: {"Key is ~s", ["[REDACTED_ANTHROPIC_KEY]"]}} = result
    end
  end

  describe "filter/2 edge cases" do
    test "handles events without msg key" do
      event = %{level: :debug, meta: %{}}

      result = LoggerFilter.filter(event, [])

      assert result == event
    end

    test "handles binary messages directly" do
      event = %{msg: "sk-ant-api03-abc123def456ghi789jkl012mno345pqr678stu901vwx234yz"}

      result = LoggerFilter.filter(event, [])

      assert %{msg: "[REDACTED_ANTHROPIC_KEY]"} = result
    end
  end
end
