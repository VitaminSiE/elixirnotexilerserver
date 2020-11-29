defmodule Elixirnotexilerserver do
  require Logger
  use Agent
  use Task

  def start(_type, _args) do

    #start Config GenServer
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
                :gen_tcp.send(socket, "HTTP/1.1 404\r\nContent-Type: text/plain\r\n\r\nRequested File Not found")
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

  def detect_request(request_raw) do
    headers = String.split(request_raw, "\r\n")

    if length(headers) > 1 do
      [request_header_first_line | header_rest] = headers
      request_header_first_line_seperated = String.split(request_header_first_line, " ")

      if length(request_header_first_line_seperated) > 1 do
        [method | rest_of_first_line] = request_header_first_line_seperated
        [path | _] = rest_of_first_line
        %{validity: :valid, method: method, path: path, header_rest: header_rest}
      end
    else
      %{validity: :invalid, method: "", path: "", header_rest: ""}
    end
  end

  def process_headers(headers) do
    headers_list =
      Enum.map(headers, fn line ->
        if String.contains?(line, ":") do
          [headerTitle | headerValue] = String.split(line, ": ")
          headerValue = Enum.join(headerValue, ":")
          {headerTitle, headerValue}
        else
          {:misformed}
          IO.puts("Misformed header")
        end
      end)

    headers_list

    # if headers =~ "\r\n" do
    #   header_lines = String.split(headers, "\r\n")

    # else
    #   []
    # end
  end

  def loopsendmessage(interval, socket, loopnum) do
    :gen_tcp.send(socket, "Hi")
    :timer.sleep(interval)

    if loopnum > 10,
      do:
        (
          :gen_tcp.close(socket)
          {:done, "Socket Closed After 10 HIs"}
        ),
      else: loopsendmessage(interval, socket, loopnum + 1)
  end

  def getdefinitions(word) do
    word
  end

  def sendmessage(text, socket) do
    :gen_tcp.send(socket, text)
  end
end
