defmodule Storybook.BattleV2.BattleCharacterHealth do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.battle_character_health/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          class: "w-[80px]",
          current_health: 60,
          max_health: 100
        }
      },
      %Variation{
        id: :low,
        attributes: %{
          class: "w-[80px]",
          current_health: 1,
          max_health: 100
        }
      },
      %Variation{
        id: :max,
        attributes: %{
          class: "w-[80px]",
          current_health: 100,
          max_health: 100
        }
      }
    ]
  end
end
