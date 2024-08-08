defmodule Tarragon.Ecspanse.Battles.Components.ActionState do
  @moduledoc """
  This is essentilly a tag to be able to identify available actions.
  """
  use Ecspanse.Component,
    state: [is_available: true, is_scheduled: false],
    tags: []
end
