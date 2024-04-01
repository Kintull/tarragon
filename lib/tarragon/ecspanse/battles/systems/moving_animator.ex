defmodule Tarragon.Ecspanse.Battles.Systems.MovingAnimator do
  alias Tarragon.Ecspanse.Battles.Components

  use Ecspanse.System,
    lock_components: [Components.Position, Components.Animations.Moving]

  def run(%Ecspanse.Frame{} = frame) do
    Ecspanse.Query.list_tagged_components([:animation, :moving])
    |> Enum.each(fn moving ->
      with entity <- Ecspanse.Query.get_component_entity(moving),
           {:ok, position} <- Components.Position.fetch(entity) do
        delta_x =
          (moving.from - moving.to) * frame.delta / moving.duration

        new_x = position.x - delta_x

        new_x =
          cond do
            moving.from < moving.to -> min(new_x, moving.to)
            moving.from > moving.to -> max(new_x, moving.to)
          end

        if new_x == moving.to do
          Ecspanse.Command.update_component!(position, x: moving.to)
          Ecspanse.Command.remove_component!(moving)
        else
          Ecspanse.Command.update_component!(position, x: new_x)
        end
      end
    end)
  end
end
