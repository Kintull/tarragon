defmodule Storybook.Components.BallBlueSvg do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.ball_blue_svg/1

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
