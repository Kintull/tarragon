defmodule Tarragon.Ecspanse.Battles.Components.PositionTemplate do
  use Ecspanse.Template.Component,
    state: [x: 0, y: 0, z: 0]

  @impl true
  @spec validate(nil | maybe_improper_list() | map()) :: :ok | {:error, <<_::64, _::_*8>>}
  def validate(state) do
    with :ok <- validate_coordinate(state[:x]) do
      validate_coordinate(state[:y])
    end
  end

  def validate_coordinate(val) when is_number(val), do: :ok
  def validate_coordinate(val), do: {:error, "#{inspect(val)} must be a number"}
end
