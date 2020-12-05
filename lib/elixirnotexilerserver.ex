defmodule Elixirnotexilerserver do
  require Logger
  use Agent
  use Task

  def start(_type, _args) do
    # start Config GenServer
    {:ok, registry} = Elixirnotexilerserver.Config.start_link()
    Process.register(registry, :config_server)
    IO.puts("Starting Listening")
    listen(4040)
    # {:ok, _fakeagent} = Agent.start_link(fn -> %{} end)
  end

  def listen(port) do
    children = [
      {Task.Supervisor, name: Elixirnotexilerserver.PortSupervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)

    IO.puts("Listening to port : #{port}")
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    accept_connection(socket)
  end

  def accept_connection(socket) do
    {:ok, client} = :gen_tcp.accept(socket)

    {:ok, task} =
      Task.Supervisor.start_child(Elixirnotexilerserver.PortSupervisor, fn ->
        process_socket(client)
      end)

    :gen_tcp.controlling_process(client, task)
    accept_connection(socket)
  end

  def process_socket(socket) do
    {:ok, line} = :gen_tcp.recv(socket, 0)

    # IO.puts("RAW LINE \n" <> line)
    line_processed = detect_request(line)

    if line_processed.validity == :valid do
      line_headers_list = process_headers(line_processed.header_rest)

      Enum.map(line_headers_list, fn headerData ->
        if headerData == {:misformed} do
          Process.exit(self(), "Socket Closed : Misformed header")
        end
      end)

      case line_processed.method do
        "GET" ->
          IO.puts("GET request")
          IO.puts("#{__DIR__}/lib/www#{line_processed.path}")

          case File.read("#{__DIR__}/www#{line_processed.path}") do
            {:ok, content} ->
              :gen_tcp.send(socket, "HTTP/1.1 200\r\nContent-Type: text/plain\r\n\r\n#{content}")

            {:error, reason} ->
              if reason === :enoent do
                :gen_tcp.send(
                  socket,
                  "HTTP/1.1 404\r\nContent-Type: text/plain\r\n\r\nRequested File Not found"
                )
              end
          end

          :gen_tcp.close(socket)

        "POST" ->
          IO.puts("POST request")

        "PUT" ->
          IO.puts("PUT request")

        "PATCH" ->
          IO.puts("PATCH request")

        "DELETE" ->
          IO.puts("DELETE request")

        "HEAD" ->
          IO.puts("HEAD request")

        "OPTIONS" ->
          IO.puts("OPTIONS request")

        "TRACE" ->
          IO.puts("TRACE request")

        true ->
          nil
      end
    else
    end

    process_socket(socket)
  end
end
