defmodule Tarragon.Ecspanse.Components.InventoryItems.Potion do
  @moduledoc """
  A Potion
  """
  use Tarragon.Ecspanse.Components.InventoryItems.Template,
    state: [type: :potion, name: "Potion", icon: "🧪"]
end
