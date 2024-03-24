defmodule Storybook.BattleV2.BattleFooterV3 do
  use PhoenixStorybook.Story, :component

  alias TarragonWeb.PageLive.BattleScreenV2

  def function, do: &Elixir.TarragonWeb.FaceComponents.battle_footer_v3/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          energy_state: BattleScreenV2.init_energy_state(),
          attack_action_state: BattleScreenV2.init_attack_action_state(),
          dodge_action_state: BattleScreenV2.init_dodge_action_state(),
          step_action_state: BattleScreenV2.init_step_action_state()

        }
      }
    ]
  end
end
