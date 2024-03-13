defmodule Storybook.Components.BorderedRectangle do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.bordered_rectangle/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          width: "60px",
          height: "50px",
          border_color: "border-stone-100",
          bg_inner: "bg-stone-700",
          bg_outer: "bg-stone-500",
          ring_border_color: "border-white",
        },
        slots: ["Button"]
      }
    ]
  end
end
