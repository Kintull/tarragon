defmodule Storybook.Components.ProgressBar do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.progress_bar/1

  def variations do
    [
      %Variation{
        id: :default
      }
    ]
  end
end
