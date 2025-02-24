defmodule GoChampsApiWeb.IncludeParserTest do
  use GoChampsApiWeb.ConnCase

  alias GoChampsApiWeb.IncludeParser

  describe "parse_include_string/1" do
    test "returns a list of keyword for a given string separeted by ," do
      assert IncludeParser.parse_include_string(
               "registration,registration.tournament,registration_responses"
             ) == [
               registration: [{:tournament, []}],
               registration_responses: []
             ]
    end
  end
end
