defmodule Storybook.Components.ActionBadge do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.action_badge/1

  def variations do
    [
      %Variation{
        id: :default
      },
      %Variation{
        id: :orange,
        attributes: %{
          bg_color: "bg-amber-500"
        }
      }
    ]
  end
end
