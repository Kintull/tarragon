defmodule Tarragon.Ecspanse.Demo.Systems.PositionChangeRequestProcessor do
  @moduledoc """
  Listens for ChangePositionEvents and updates the position if the entity has enough energy
  """
  alias Tarragon.Ecspanse.Demo.Events.ChangePositionRequest
  alias Tarragon.Ecspanse.Demo.Events
  alias Tarragon.Ecspanse.Demo.Components

  use Ecspanse.System,
    lock_components: [Components.Energy, Components.Position],
    event_subscriptions: [Events.ChangePositionRequest]

  def run(%ChangePositionRequest{direction: direction, entity_id: entity_id}, _frame) do
    with {:ok, entity} <- Ecspanse.Query.fetch_entity(entity_id),
         {:ok, {energy, position}} <-
           Ecspanse.Query.fetch_components(entity, {Components.Energy, Components.Position}) do
      if energy.current > 0 do
        updated_coordinates = update_coordinates(position, direction)

        if valid_coordinates(updated_coordinates) do
          Ecspanse.Command.update_components!([
            {energy, current: energy.current - 1},
            {position, updated_coordinates}
          ])

          Ecspanse.event({Events.PositionChanged, entity_id: entity_id})
          Ecspanse.event({Events.EnergyChanged, entity_id: entity_id})
        end
      end
    end
  end

  defp valid_coordinates(x: x, y: y)
       when x >= -10 and x <= 10 and y >= -10 and y <= 10,
       do: true

  defp valid_coordinates(_position), do: false

  defp update_coordinates(%Components.Position{x: x, y: y}, direction) do
    case direction do
      :up -> [x: x, y: y + 1]
      :down -> [x: x, y: y - 1]
      :left -> [x: x - 1, y: y]
      :right -> [x: x + 1, y: y]
      _ -> [x: x, y: y]
    end
  end
end
