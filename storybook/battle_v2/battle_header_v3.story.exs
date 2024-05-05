defmodule Storybook.BattleV2.BattleHeaderV3 do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.battle_header_v3/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          blue_score: 1,
          red_score: 5,
          time_left: 30
        }
      }
    ]
  end
end
