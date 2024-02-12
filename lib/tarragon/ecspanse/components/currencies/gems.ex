defmodule Tarragon.Ecspanse.Components.Currencies.Gems do
  @moduledoc """
  Gems to be found and coveted
  """
  use Tarragon.Ecspanse.Components.Currencies.Template,
    state: [type: :gems, name: "Gems", icon: "💎", amount: 0]
end
