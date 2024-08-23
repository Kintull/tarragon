defmodule Tarragon.Ecspanse.Battles.Entities.GridEntity do
  @moduledoc """
  Factory for bullets
  """
  alias Tarragon.Ecspanse.Battles.Components

  def new(parent) do
    {Ecspanse.Entity, components: [Components.Grid], parents: [parent]}
  end
end
