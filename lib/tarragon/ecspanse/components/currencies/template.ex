defmodule Tarragon.Ecspanse.Components.Currencies.Template do
  @moduledoc """
  the template for any form of currency
  """

  use Ecspanse.Template.Component,
    state: [:type, :name, icon: "$", amount: 0],
    tags: [:currency]

  @impl true
  def validate(state) do
    validate_amount(state[:amount])
  end

  defp validate_amount(amount) when is_integer(amount) and amount >= 0, do: :ok
  defp validate_amount(amount), do: {:error, "#{inspect(amount)} must be a non-negative integer"}
end
