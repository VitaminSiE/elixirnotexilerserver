defmodule Elixirnotexilerserver.Config do
  use GenServer
  require Jason

  # Client

  @doc """
    Starts the registry.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
    Get the definition from Map
    Return definition if available,
    "No Definitions Available" if not.
  """
  def get_definition(server, word) do
    result = GenServer.call(server, {:get_def, word})

    if result == :notfound,
      do: "No Definitions Available",
      else: result
  end

  def add_definition(server, word, definition) do
    GenServer.cast(server, {:add_def, word, definition})
  end

  def remove_definition(server, word) do
    GenServer.cast(server, {:remove_def, word})
  end

  # Sever

  @impl true
  def init(:ok) do
    IO.puts("GenServer : #{__DIR__}/../config.json")

    case File.read("#{__DIR__}/../configo.json") do
      {:ok, fileData} ->
        {:ok, Jason.decode!(fileData)}

      {:error, reason} ->
        if reason === :enoent do
          GenServer.stop(self(), "Config.json not found")
        else
          GenServer.stop(self(), reason)
        end
    end

    # case File.read("#{__DIR__}/www#{line_processed.path}") do
    #   {:ok, content} ->
    #     :gen_tcp.send(socket, "HTTP/1.1 200\r\nContent-Type: text/plain\r\n\r\n#{content}")

    #   {:error, reason} ->
    #     if reason === :enoent do
    #       :gen_tcp.send(socket, "HTTP/1.1 404\r\nContent-Type: text/plain\r\n\r\nRequested File Not found")
    #     end
    # end
  end

  @impl true
  def handle_call({:get_port}, _from, configData) do
    if Map.has_key?(configData, "port") do
      {:ok, port} = Map.fetch(configData, "port")
      {:reply, port, configData}
    else
      {:reply, 4040, configData}
    end
  end

  @impl true
  def handle_call({:get_public_folder}, _from, configData) do
    if Map.has_key?(configData, "public_folder") do
      {:ok, publicPath} = Map.fetch(configData, "port")

      {:reply, publicPath, configData}
    else
      {:reply, 4040, configData}
    end
  end

  @impl true
  def handle_call({:is_file_public?}, _from, configData) do
    if Map.has_key?(configData, "port") do
      {:ok, port} = Map.fetch(configData, "port")
      {:reply, port, configData}
    else
      {:reply, 4040, configData}
    end
  end

  @impl true
  def handle_cast({:add_def, word, def}, map) do
    if Map.has_key?(map, String.downcase(word)) do
      {:noreply, map}
    else
      # {:ok, bucket} = KV.Bucket.start_link([])
      {:noreply, Map.put(map, String.downcase(word), def)}
    end
  end

  @impl true
  def handle_cast({:remove_def, word}, map) do
    if Map.has_key?(map, String.downcase(word)) do
      {:noreply, Map.delete(map, String.downcase(word))}
    end
  end
end
