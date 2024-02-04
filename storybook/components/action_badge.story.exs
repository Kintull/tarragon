defmodule Storybook.Components.ActionBadge do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.action_badge/1

  def variations do
    [
      %Variation{
        id: :default,
        slots: [~s|<div class="w-[10rem] h-[10rem]"> hello </div> |]
      },
      %Variation{
        id: :orange,
        attributes: %{
          bg_color: "bg-amber-500"


        },
        slots: [~s|<div class="w-[10rem] h-[10rem]"> hello </div> |]
      }
    ]
  end
end
