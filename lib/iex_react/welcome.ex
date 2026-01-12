defmodule IExReAct.Welcome do
  @moduledoc """
  Welcome banner and status display for IExReAct.
  """

  @banner """
  \e[36m
   ██╗███████╗██╗  ██╗    ██████╗ ███████╗ █████╗  ██████╗████████╗
   ██║██╔════╝╚██╗██╔╝    ██╔══██╗██╔════╝██╔══██╗██╔════╝╚══██╔══╝
   ██║█████╗   ╚███╔╝     ██████╔╝█████╗  ███████║██║        ██║
   ██║██╔══╝   ██╔██╗     ██╔══██╗██╔══╝  ██╔══██║██║        ██║
   ██║███████╗██╔╝ ██╗    ██║  ██║███████╗██║  ██║╚██████╗   ██║
   ╚═╝╚══════╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝   ╚═╝
  \e[0m\e[33m        A ReAct Agent with TrumanShell Integration\e[0m
  """

  @doc """
  Prints the welcome banner and status information.
  """
  def print do
    IO.puts(@banner)
    print_status()
    print_usage()
    :ok
  end

  defp print_status do
    IO.puts("")
    IO.puts("  \e[1m📊 Status\e[0m")
    IO.puts("  ─────────────────────────────────────────────")

    # Check API key
    api_key = System.get_env("ANTHROPIC_API_KEY")
    api_status = if api_key && String.length(api_key) > 10 do
      masked = String.slice(api_key, 0..7) <> "..." <> String.slice(api_key, -4..-1)
      "  \e[32m✓\e[0m API Key:      \e[32mConfigured\e[0m (#{masked})"
    else
      "  \e[31m✗\e[0m API Key:      \e[31mNot configured\e[0m (set ANTHROPIC_API_KEY)"
    end
    IO.puts(api_status)

    # Check TrumanShell
    truman_status = if Code.ensure_loaded?(TrumanShell) do
      "  \e[32m✓\e[0m TrumanShell:  \e[32mLoaded\e[0m"
    else
      "  \e[31m✗\e[0m TrumanShell:  \e[31mNot available\e[0m"
    end
    IO.puts(truman_status)

    IO.puts("")
  end

  defp print_usage do
    IO.puts("  \e[1m🚀 Quick Start\e[0m")
    IO.puts("  ─────────────────────────────────────────────")
    IO.puts("  \e[36mIExReAct.start()\e[0m          # Start the agent")
    IO.puts("  \e[36mIExReAct.chat(\"ls\")\e[0m       # Send a message")
    IO.puts("  \e[36mIExReAct.clear()\e[0m          # Clear session")
    IO.puts("")
    IO.puts("  \e[1m🛠  Available Tools\e[0m")
    IO.puts("  ─────────────────────────────────────────────")
    IO.puts("  • \e[33mshell\e[0m      - Execute shell commands (ls, cat, grep...)")
    IO.puts("  • \e[33mread_file\e[0m  - Read files from vault/")
    IO.puts("  • \e[33mwrite_file\e[0m - Write files to vault/")
    IO.puts("  • \e[33mlist_files\e[0m - List files matching a pattern")
    IO.puts("  • \e[33mfetch_url\e[0m  - Fetch from allowlisted URLs")
    IO.puts("")
  end
end
