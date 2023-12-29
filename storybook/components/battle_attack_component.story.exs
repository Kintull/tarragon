defmodule Storybook.Components.BattleAttackComponent do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.battle_attack_component/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
        }
      },

      %Variation{
        id: :disabled,
        attributes: %{
          disabled: true
        }
      }

    ]
  end
end
