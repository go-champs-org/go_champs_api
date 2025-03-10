defmodule GoChampsApiWeb.UploadController do
  use GoChampsApiWeb, :controller

  def presigned_url(conn, %{"filename" => filename, "content_type" => content_type}) do
    with {:ok, _} <- validate_file_size(conn.params),
         {:ok, _} <- validate_file_type(content_type),
         {:ok, presigned_url} <-
           GoChampsApi.Infrastructure.R2.RegistrationConsents.generate_presigned_upload_url(
             filename,
             content_type
           ) do
      json(conn, %{data: %{url: presigned_url}})
    else
      {:error, reason} -> handle_error(conn, reason)
    end
  end

  def delete_file(conn, %{"url" => url}) do
    filename =
      String.split(url, "/")
      |> List.last()
      |> URI.decode()

    IO.inspect(filename)
    IO.inspect("filename")
    IO.inspect(url)
    IO.inspect("url")

    case GoChampsApi.Infrastructure.R2.RegistrationConsents.delete_file(filename) do
      {:ok, _} -> send_resp(conn, :no_content, "")
      {:error, reason} -> handle_error(conn, reason)
    end
  end

  # Validation helpers
  defp validate_file_size(%{"size" => size}) do
    # 5MB
    max_size = 5_000_000
    if size > max_size, do: {:error, "File too large"}, else: {:ok, nil}
  end

  defp validate_file_type(content_type) do
    allowed_types = ["image/jpeg", "image/png", "application/pdf"]
    if content_type in allowed_types, do: {:ok, nil}, else: {:error, "Invalid file type"}
  end

  # Error handler
  defp handle_error(conn, reason) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: reason})
  end
end
