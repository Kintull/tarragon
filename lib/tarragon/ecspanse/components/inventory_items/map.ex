defmodule Tarragon.Ecspanse.Components.InventoryItems.Map do
  @moduledoc """
  A Map
  """
  use Tarragon.Ecspanse.Components.InventoryItems.Template,
    state: [type: :map, name: "Map", icon: "🗺️"]
end
