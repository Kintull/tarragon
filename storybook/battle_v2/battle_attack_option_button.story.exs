defmodule Storybook.BattleV2.BattleAttackOptionButton do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.battle_attack_option_button/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          state: :idle,
          option_id: 1,
          name: "Body",
          class: ""
        }
      },
      %Variation{
        id: :selected,
        attributes: %{
          state: :selected,
          option_id: 1,
          name: "Body",
          class: ""
        }
      },
      %Variation{
        id: :active,
        attributes: %{
          state: :active,
          option_id: 1,
          name: "Body",
          class: ""
        }
      }
    ]
  end
end
