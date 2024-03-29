defmodule Tarragon.Ecspanse.Battles.Projections.Position do
  alias Tarragon.Ecspanse.ProjectionUtils
  alias Tarragon.Ecspanse.Battles.Components

  def project_position(%Components.Position{} = position) do
    projection = ProjectionUtils.project(position)
    # .05 increments
    %{projection | x: floor(projection.x * 20) / 20, y: floor(projection.y * 20) / 20}
  end
end
