defmodule Storybook.Components.BattleActionButtonV3 do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.action_button_v3/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          state: :idle,
          action: "step",
          energy_cost: 1
        }
      },
      %Variation{
        id: :active,
        attributes: %{
          state: :active,
          action: "step",
          energy_cost: 1
        }
      },
      %Variation{
        id: :unavailable,
        attributes: %{
          state: :unavailable,
          action: "step",
          energy_cost: 1
        }
      }


    ]
  end
end
