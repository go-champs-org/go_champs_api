defmodule GoChampsApiWeb.UserController do
  use GoChampsApiWeb, :controller

  alias GoChampsApi.Accounts
  alias GoChampsApi.Accounts.User
  alias GoChampsApi.Organizations
  alias GoChampsApiWeb.Auth.Guardian

  action_fallback GoChampsApiWeb.FallbackController

  plug GoChampsApiWeb.Plugs.AuthorizedUser when action in [:show]

  require Logger

  def create(conn, %{"user" => user_params}) do
    with {:ok, _response} <- Recaptcha.verify(user_params["recaptcha"]) do
      with {:ok, %User{} = user} <- Accounts.create_user(user_params),
           {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
        conn
        |> put_status(:created)
        |> render("user.json", %{user: user, token: token})
      end
    end
  end

  def create_with_facebook(conn, %{"user" => user_params}) do
    with {:ok, _response} <- Recaptcha.verify(user_params["recaptcha"]) do
      with {:ok, %User{} = user} <- Accounts.create_user_with_facebook(user_params),
           {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
        conn
        |> put_status(:created)
        |> render("user.json", %{user: user, token: token})
      end
    end
  end

  def show(conn, %{"username" => username}) do
    case Accounts.get_by_username!(username) do
      {:ok, user} ->
        user_organizations = Organizations.list_organizations_by_member(username)
        render(conn, "show.json", %{user: user, organizations: user_organizations})

      {:error, status} ->
        conn
        |> put_status(status)
        |> text("Error")
    end
  end

  def update(conn, %{"user" => user_params}) do
    if user_params["email"] != nil and user_params["password"] != nil do
      {:ok, current_user} = Accounts.get_by_username!(user_params["username"])

      with {:ok, _response} <- Recaptcha.verify(user_params["recaptcha"]) do
        with {:ok, %User{} = user} <- Accounts.update_user(current_user, user_params),
             {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
          conn
          |> put_status(:ok)
          |> render("user.json", %{user: user, token: token})
        end
      end
    else
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{email: "invalid email"})
    end
  end

  def signin(conn, %{"username" => username, "password" => password}) do
    with {:ok, user, token} <- Guardian.authenticate(username, password) do
      conn
      |> render("user.json", %{user: user, token: token})
    end
  end

  def signin_with_facebook(conn, %{"facebook_id" => facebook_id}) do
    with {:ok, user, token} <- Guardian.authenticate_by_facebook(facebook_id) do
      conn
      |> render("user.json", %{user: user, token: token})
    end
  end

  def recovey_account(conn, %{"email" => email, "recaptcha" => recaptcha}) do
    with {:ok, _response} <- Recaptcha.verify(recaptcha) do
      with {:ok, %User{} = user} <- Accounts.get_by_email!(email) do
        with {:ok, %User{} = user_token} <- Accounts.update_recovery_token(user) do
          body =
            Poison.encode!(%{
              service_id: System.get_env("EMAILJS_SERVICE"),
              template_id: System.get_env("EMAILJS_RECOVERY_PASSWORD"),
              user_id: System.get_env("EMAILJS_USER_ID"),
              template_params: %{
                recovery_token: user_token.recovery_token,
                to_email: user_token.email,
                username: user_token.username
              }
            })

          url = System.get_env("EMAILJS_URL")

          case HTTPoison.post(url, body, [
                 {"Content-Type", "application/json"}
               ]) do
            {:ok, %HTTPoison.Response{status_code: 200, body: _body}} ->
              send_resp(conn, 200, "")

            error ->
              Logger.error("Error sending email: #{inspect(error)}")
              IO.inspect(error)
              send_resp(conn, 500, "")
          end
        end
      end
    end
  end

  def reset_password(conn, %{"user" => user_params}) do
    with {:ok, _response} <- Recaptcha.verify(user_params["recaptcha"]) do
      with {:ok, %User{} = user} <- Accounts.get_by_username!(user_params["username"]) do
        with {:ok, _} <- Accounts.reset_password(user, user_params) do
          send_resp(conn, 200, "")
        end
      end
    end
  end
end
