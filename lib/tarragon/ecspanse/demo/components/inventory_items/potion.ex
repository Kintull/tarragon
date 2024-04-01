defmodule Tarragon.Ecspanse.Demo.Components.InventoryItems.Potion do
  @moduledoc """
  A Potion
  """
  use Tarragon.Ecspanse.Demo.Components.InventoryItems.Template,
    state: [type: :potion, name: "Potion", icon: "🧪"]
end
