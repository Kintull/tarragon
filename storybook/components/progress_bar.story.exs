defmodule Storybook.Components.ProgressBar do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.progress_bar/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          img_url: "/images/blood-drop.webp",
          collapsable: false,
          class: "w-[100px]"
        }
      },

      %Variation{
        id: :collapsable,
        attributes: %{
          img_url: "/images/blood-drop.webp",
          collapsable: true,
          class: "w-[100px]"
        }
      }

    ]
  end
end
