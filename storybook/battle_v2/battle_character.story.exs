defmodule Storybook.BattleV2.BattleCharacter do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.battle_character/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          facing: "front",
          class: "",
          height: "140",
          width: "70",
          current_health: 60,
          max_health: 100,
          style: "",
          is_ally: true,
          is_player: true,
          is_target: false
        }
      }
    ]
  end
end
