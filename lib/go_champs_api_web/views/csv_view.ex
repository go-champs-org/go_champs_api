defmodule GoChampsApiWeb.CSVView do
  def render("csv.csv", %{data: data, headers: headers}) do
    csv_content =
      [headers | data]
      |> CSV.encode()
      |> Enum.to_list()
      |> Enum.join("")

    csv_content
  end
end
