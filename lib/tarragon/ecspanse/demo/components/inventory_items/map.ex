defmodule Tarragon.Ecspanse.Demo.Components.InventoryItems.Map do
  @moduledoc """
  A Map
  """
  use Tarragon.Ecspanse.Demo.Components.InventoryItems.Template,
    state: [type: :map, name: "Map", icon: "🗺️"]
end
