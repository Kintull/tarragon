defmodule Storybook.Components.BattleSideButton do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.side_button/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          text: "Reset",
          state: :available
        }
      },
      %Variation{
        id: :unavailable,
        attributes: %{
          text: "Reset",
          state: :unavailable
        }
      }
    ]
  end
end
