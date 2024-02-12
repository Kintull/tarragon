defmodule Tarragon.Ecspanse.Components.Market do
  @moduledoc """
  Markets have items for sale
  """
  use Ecspanse.Component, state: [name: "Moe's Used Goods"], tags: [:market]
end
