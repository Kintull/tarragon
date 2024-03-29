defmodule Tarragon.Ecspanse.Battles.Components.Actions.Dodge do
  @moduledoc """
  Dodging reduces your changes to be hit
  """
  use Tarragon.Ecspanse.Battles.Components.Actions.Template,
    state: [
      name: "Dodge",
      action_group: :defense,
      icon: "🫣",
      action_point_cost: 2,
      incoming_miss_chance_modifier: 200.00
    ],
    tags: [:dodge]

  @impl true
  def validate(state) do
    validate_incoming_miss_chance_modifier(state.incoming_miss_chance_modifier)
  end

  defp validate_incoming_miss_chance_modifier(modifier)
       when is_number(modifier) and modifier >= 0,
       do: :ok

  defp validate_incoming_miss_chance_modifier(modifier),
    do: {:error, "#{inspect(modifier)} must be a non-negative number"}
end
