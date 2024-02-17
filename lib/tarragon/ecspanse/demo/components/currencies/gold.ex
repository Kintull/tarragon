defmodule Tarragon.Ecspanse.Demo.Components.Currencies.Gold do
  @moduledoc """
  Gold to be found and spent
  """
  use Tarragon.Ecspanse.Demo.Components.Currencies.Template,
    state: [type: :gold, name: "Gold", icon: "🪙", amount: 0]
end
