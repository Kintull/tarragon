defmodule Storybook.CoreComponents.HealthProgressBar do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.health_progress_bar/1

  def variations do
    [
      %Variation{
        id: :default
      }
    ]
  end
end
