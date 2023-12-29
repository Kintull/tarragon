defmodule Storybook.Components.BattleMoveComponent do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.battle_move_component/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
        }
      }
    ]
  end
end
