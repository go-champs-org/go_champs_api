defmodule GoChampsApi.ExAwsHTTPoisonAdapter do
  @moduledoc """
  Adapter to make ExAws use HTTPoison instead of Hackney
  """
  @behaviour ExAws.Request.HttpClient

  def request(method, url, body, headers, http_opts) do
    options =
      http_opts
      |> Keyword.take([:timeout, :connect_timeout])
      |> Keyword.put(:params, http_opts[:query])
      |> Keyword.put(:ssl, http_opts[:ssl_options])

    case HTTPoison.request(method, url, body, headers, options) do
      {:ok, %HTTPoison.Response{status_code: status, body: body, headers: headers}} ->
        {:ok, %{status_code: status, body: body, headers: headers}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
