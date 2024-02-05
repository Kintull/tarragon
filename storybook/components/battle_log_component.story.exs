defmodule Storybook.Components.BattleLogComponent do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.battle_log_component/1

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
