defmodule Tarragon.Ecspanse.Demo.Components.InventoryItems.Compass do
  @moduledoc """
  Compass
  """
  use Tarragon.Ecspanse.Demo.Components.InventoryItems.Template,
    state: [type: :compass, name: "Compass", icon: "🧭"]
end
