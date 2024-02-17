defmodule Tarragon.Ecspanse.Demo.Systems.MaybeFindMoney do
  @moduledoc """
  When a hero moves, they may find Gold or Gems
  """
  alias Tarragon.Ecspanse.Demo.Events
  alias Tarragon.Ecspanse.Demo.Components.Currencies
  alias Tarragon.Ecspanse.Demo.Components

  use Ecspanse.System,
    lock_components: [Currencies.Gems, Currencies.Gold],
    event_subscriptions: [Events.PositionChanged]

  def run(%Events.PositionChanged{entity_id: entity_id}, _frame) do
    with true <- found_money?(),
         {:ok, entity} <- Ecspanse.Query.fetch_entity(entity_id),
         true <- Ecspanse.Query.has_component?(entity, Components.Hero),
         currency_component <- pick_currency_component(),
         {:ok, heros_currency_component} <-
           Ecspanse.Query.fetch_component(entity, currency_component) do
      Ecspanse.Command.update_component!(heros_currency_component,
        amount: heros_currency_component.amount + 1
      )
    end
  end

  defp found_money?, do: if(Enum.random(1..100) < 33, do: true, else: false)
  defp pick_currency_component, do: Enum.random([Currencies.Gems, Currencies.Gold])
end
