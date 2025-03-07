defmodule GoChampsApi.Infrastructure.R2.RegistrationConsents do
  @bucket "registration-consents"

  def generate_presigned_upload_url(filename, content_type) do
    config = ExAws.Config.new(:s3)

    ExAws.S3.presigned_url(
      config,
      :put,
      @bucket,
      "uploads/#{filename}",
      # 1 hour expiration
      expires_in: 3600,
      content_type: content_type
    )
  end

  def upload_file(filename, content) do
    ExAws.S3.put_object(@bucket, "uploads/#{filename}", content)
    |> ExAws.request()
  end
end
