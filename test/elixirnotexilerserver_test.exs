defmodule ElixirnotexilerserverTest do
  use ExUnit.Case
  doctest Elixirnotexilerserver

  setup do
    server = start_supervised!(Elixirnotexilerserver.Definitions)
    %{server: server}
  end

  test "Testing Server Definitions service", %{server: server} do
    assert Elixirnotexilerserver.Definitions.get_definition(server,"hello") == "Greeting"
  end
end
