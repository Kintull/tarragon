defmodule Storybook.Components.BattleConfirmComponent do
  use PhoenixStorybook.Story, :component

  def function, do: &Elixir.TarragonWeb.FaceComponents.battle_confirm_component/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
        }
      },
      %Variation{
        id: :submitting,
        attributes: %{
          state: "submitting"
        }
      },
      %Variation{
        id: :submitted,
        attributes: %{
          state: "submitted"
        }
      }

    ]
  end
end
