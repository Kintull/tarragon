defmodule Tarragon.Ecspanse.Battles.BotAi do
  @moduledoc """
  The Ai to run any bot combatants
  """
  alias Tarragon.Ecspanse.Battles.Components

  def choose_actions(entity, available_action_entities) do
    with {:ok, _health} <- Ecspanse.Query.fetch_components(entity, {Components.Health}) do
      Enum.random(available_action_entities)
    end
  end
end
