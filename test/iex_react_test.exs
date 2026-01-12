defmodule IExReActTest do
  use ExUnit.Case

  describe "start/0" do
    test "starts an agent and returns {:ok, pid}" do
      assert {:ok, pid} = IExReAct.start()
      assert is_pid(pid)
    end
  end

  describe "chat/1" do
    test "returns error when agent not started" do
      # Clear any existing agent from process dictionary
      Process.delete(:iex_react_agent)
      assert {:error, :not_started} = IExReAct.chat("hello")
    end
  end

  describe "clear/0" do
    test "returns error when agent not started" do
      Process.delete(:iex_react_agent)
      assert {:error, :not_started} = IExReAct.clear()
    end

    test "clears the agent when started" do
      {:ok, _pid} = IExReAct.start()
      assert :ok = IExReAct.clear()
      assert {:error, :not_started} = IExReAct.chat("hello")
    end
  end

  describe "history/0" do
    test "returns error when agent not started" do
      Process.delete(:iex_react_agent)
      assert {:error, :not_started} = IExReAct.history()
    end
  end
end
