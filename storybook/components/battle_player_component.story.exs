defmodule Storybook.Components.BattlePlayerComponent do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.battle_player_component/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
        }
      },
      %Variation{
        id: :dying,
        attributes: %{
          current_hp: 10
        }
      },
      %Variation{
        id: :dead,
        attributes: %{
          current_hp: 0
        }
      }


    ]
  end
end
