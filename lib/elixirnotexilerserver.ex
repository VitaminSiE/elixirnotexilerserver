defmodule Elixirnotexilerserver do
  use Agent
  def start(_type, _args) do
    IO.puts("Sup biatch")
    {:ok, _fakeagent} = Agent.start_link(fn -> %{} end)
  end
end
