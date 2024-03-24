defmodule Storybook.BattleV2.BattleSideCharactersBar do
  use PhoenixStorybook.Story, :component

  alias TarragonWeb.PageLive.BattleScreenV2

  def function, do: &Elixir.TarragonWeb.FaceComponents.battle_side_characters_bar/1

  def variations do
    [
      %Variation{
        id: :blue_left,
        attributes: %{
          color_scheme: "blue",
          display_side: "left",
          current_hp: 5,
          max_hp: 20,
          character_ids: [1],
          avatars_by_ids: %{1 => "https://via.placeholder.com/46x46"},
          current_health_points_by_ids: %{1 => 5},
          max_health_points_by_ids: %{1 => 20},
        }
      },
      %Variation{
        id: :blue_left_2,
        attributes: %{
          color_scheme: "blue",
          display_side: "left",
          current_hp: 5,
          max_hp: 20,
          character_ids: [1,2],
          avatars_by_ids: %{1 => "https://via.placeholder.com/46x46", 2 => "https://via.placeholder.com/46x46"},
          current_health_points_by_ids: %{1 => 5, 2 => 14},
          max_health_points_by_ids: %{1 => 20, 2 => 20},
        }
      },
      %Variation{
        id: :red_left,
        attributes: %{
          color_scheme: "red",
           display_side: "left",
          current_hp: 5,
          max_hp: 20,
          character_ids: [1],
          avatars_by_ids: %{1 => "https://via.placeholder.com/46x46"},
          current_health_points_by_ids: %{1 => 5},
          max_health_points_by_ids: %{1 => 20},
        }
      },
      %Variation{
        id: :blue_right,
        attributes: %{
          color_scheme: "blue",
          display_side: "right",
          current_hp: 5,
          max_hp: 20,
          character_ids: [1],
          avatars_by_ids: %{1 => "https://via.placeholder.com/46x46"},
          current_health_points_by_ids: %{1 => 5},
          max_health_points_by_ids: %{1 => 20},
        }
      },
      %Variation{
        id: :red_right,
        attributes: %{
          color_scheme: "red",
           display_side: "right",
          current_hp: 5,
          max_hp: 20,
          character_ids: [1],
          avatars_by_ids: %{1 => "https://via.placeholder.com/46x46"},
          current_health_points_by_ids: %{1 => 5},
          max_health_points_by_ids: %{1 => 20},
        }
      }
    ]
  end
end
