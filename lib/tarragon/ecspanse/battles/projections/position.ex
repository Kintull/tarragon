defmodule Tarragon.Ecspanse.Battles.Projections.Position do
  alias Tarragon.Ecspanse.ProjectionUtils
  alias Tarragon.Ecspanse.Battles.Components

  def project_position(%Components.Position{} = position) do
    ProjectionUtils.project(position)
  end
end
