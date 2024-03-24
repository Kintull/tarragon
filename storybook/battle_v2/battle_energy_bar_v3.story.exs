defmodule Storybook.BattleV2.BattleEnergyBarV3 do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.battle_energy_bar_v3/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          energy_state: %{
            name: :energy_state,
            max_energy: 3,
            current_energy: 3,
            energy_regen: 2
          },
        class: "w-[215px] h-[54px]"
        }
      }
    ]
  end
end
