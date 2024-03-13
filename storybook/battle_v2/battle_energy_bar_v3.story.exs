defmodule Storybook.BattleV2.BattleAttackOptionButton do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.battle_energy_bar_v3/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{

        }
      }
    ]
  end
end
