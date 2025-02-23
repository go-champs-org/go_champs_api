defmodule GoChampsApiWeb.RegistrationResponseView do
  use GoChampsApiWeb, :view
  alias GoChampsApiWeb.RegistrationResponseView

  def render("index.json", %{registration_responses: registration_responses}) do
    %{
      data:
        render_many(
          registration_responses,
          RegistrationResponseView,
          "registration_response.json"
        )
    }
  end

  def render("show.json", %{registration_response: registration_response}) do
    %{
      data:
        render_one(registration_response, RegistrationResponseView, "registration_response.json")
    }
  end

  def render("registration_response.json", %{registration_response: registration_response}) do
    %{
      id: registration_response.id,
      response: registration_response.response,
      status: registration_response.status
    }
  end
end
