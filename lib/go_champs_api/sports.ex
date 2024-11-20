defmodule GoChampsApi.Sports do
  @moduledoc """
  This module contains functions to retrieve sports information.
  """
  alias GoChampsApi.Sports.Sport
  alias GoChampsApi.Sports.Registry

  @spec list_sports() :: [Sport.t()]
  def list_sports() do
    Registry.sports()
  end
end
