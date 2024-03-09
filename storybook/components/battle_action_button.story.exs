defmodule Storybook.Components.ActionBadge do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.battle_action_button/1

  def variations do
    [
      %Variation{
        id: :default
      }
    ]
  end
end
