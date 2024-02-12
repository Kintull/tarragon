defmodule Tarragon.Ecspanse.Components.InventoryItems.Template do
  @moduledoc """
  The template for items that can be bought/sold and held in inventory
  """

  use Ecspanse.Template.Component,
    state: [:type, :name, icon: "ii", stackable: false, amount: 0],
    tags: [:inventory]

  @impl true
  def validate(state) do
    validate_amount(state[:amount])
  end

  defp validate_amount(amount) when is_integer(amount) and amount >= 0, do: :ok
  defp validate_amount(amount), do: {:error, "#{inspect(amount)} must be a non-negative integer"}
end
