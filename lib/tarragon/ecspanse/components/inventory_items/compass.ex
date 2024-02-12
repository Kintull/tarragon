defmodule Tarragon.Ecspanse.Components.InventoryItems.Compass do
  @moduledoc """
  Compass
  """
  use Tarragon.Ecspanse.Components.InventoryItems.Template,
    state: [type: :compass, name: "Compass", icon: "🧭"]
end
