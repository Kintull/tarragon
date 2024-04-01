defmodule Tarragon.Ecspanse.Battles.Components.AvailableAction do
  @moduledoc """
  This is essentilly a tag to be able to identify available actions.
  """
  use Ecspanse.Component,
    state: [],
    tags: [:available_action]
end
