defmodule Elixirnotexilerserver.Methods do
  @doc """
    Sends a message to the socket
    ::{:ok}
  """
  def socketSend(message, socket) do
    :gen_tcp.send(socket, message)
  end

  @doc """
    Method will process the Headers part of the request and check if there's any misformed headers

    ::list()
  """
  def processHeaders(headers) do
    headers_list =
      Enum.map(headers, fn line ->
        if String.contains?(line, ":") do
          [headerTitle | headerValue] = String.split(line, ": ")
          headerValue = Enum.join(headerValue, ":")
          {headerTitle, headerValue}
        else
          {:misformed}
        end
      end)

    headers_list
  end

  @doc """
    Method will process the First line of a HTTP request that contain the request method ect.

    Returns Request method and Requested path
  """
  def processRequestFirstLine(request_first_line) do
    # headers = String.split(request_raw, "\r\n")

    # if length(headers) > 1 do
    # [request_header_first_line | header_rest] = headers
    line_words = String.split(request_first_line, " ")

    if length(line_words) > 1 do
      [method | path_and_version] = line_words
      [path | _] = path_and_version
      %{method: method, path: path}
    end

    # else
    # %{validity: :invalid, method: "", path: "", header_rest: ""}
    # end
  end

  @doc """
    Checks whether the request is valid
  """
  def isRequestValid?(requestRaw) do
    false
  end

  def isRequestFirstLineValid?(request_first_line) do
    validity =
      if String.length(request_first_line) > 0 do
        if String.contains?(request_first_line, " ") do
          [request_method, path_and_http_ver] = String.split(request_first_line, " ", parts: 2)

          if Enum.find(
               ["GET", "POST", "PUT", "HEAD", "DELETE", "CONNECT", "OPTIONS", "TRACE"],
               false,
               fn method -> String.upcase(request_method) === method end
             ) do
            if String.length(path_and_http_ver) > 0 do
              stringArray = String.split(path_and_http_ver, " ")

              if length(stringArray) > 0 && length(stringArray) < 3 do
                true
              end
            end
          end
        end
      end

    if validity, do: true, else: false
  end

  defp isRequestHeadersValid?(request_header_lines) do
  end

  @doc """
    Returns file path or string for user defined HTTP error messages
  """
  def processConfigErrorMessage(value, public_directory) do
    if String.length(value) > 0 do
      [valueHeader, valueData] = String.split(value, "/", parts: 2)

      case String.downcase(valueHeader) do
        "string" ->
          {:string, valueData}

        "file" ->
          {:file, "#{__DIR__}/../#{public_directory}/#{valueData}"}
      end
    else
      # Default Values should be used
      {:default, ""}
    end
  end

  @doc """
    Checks whether requested file path is allowed by user Config
  """
  def isFileAllowed?(requested_file_name, public_allowed_file_list_config) do
    Enum.find(public_allowed_file_list_config, false, fn fileName ->
      fileName === requested_file_name
    end)
  end

  @doc """
    Checks whether requested file exist in public folder
  """
  def doesFileExist?(requested_file_name, public_folder_file_list) do
    Enum.find(public_folder_file_list, false, fn fileName -> fileName === requested_file_name end)
  end

  @doc """
    Returns the list of files inside public folder
  """
  def getPublicFolderFileList(public_folder) do
    File.ls!("#{__DIR__}/../#{public_folder}/")
  end

  @doc """
    Checks whether requested file exist in public folder
  """
  def getFileContent(requested_path, public_folder) do
    File.read("#{__DIR__}/../#{public_folder}/#{requested_path}")
  end
end
