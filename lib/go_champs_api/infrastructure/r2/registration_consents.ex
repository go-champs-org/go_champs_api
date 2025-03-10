defmodule GoChampsApi.Infrastructure.R2.RegistrationConsents do
  @bucket "registration-consents"

  def generate_presigned_upload_url(filename, content_type) do
    config = ExAws.Config.new(:s3)

    unique_filename = "#{Ecto.UUID.generate()}_#{filename}"

    {:ok, presigned_url} =
      ExAws.S3.presigned_url(
        config,
        :put,
        @bucket,
        "uploads/#{unique_filename}",
        # 1 hour expiration
        expires_in: 3600,
        content_type: content_type
      )

    public_url = generate_public_url(unique_filename)

    {:ok, presigned_url, public_url}
  end

  def generate_public_url(filename) do
    "https://#{@bucket}.go-champs.com/uploads/#{filename}"
  end

  def upload_file(filename, content) do
    ExAws.S3.put_object(@bucket, "uploads/#{filename}", content)
    |> ExAws.request()
  end

  def delete_file(filename) do
    ExAws.S3.delete_object(@bucket, "uploads/#{filename}")
    |> ExAws.request()
  end
end
