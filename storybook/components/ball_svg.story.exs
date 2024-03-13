defmodule Storybook.Components.BallSvg do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.ball_svg/1

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
