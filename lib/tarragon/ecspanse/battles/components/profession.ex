defmodule Tarragon.Ecspanse.Battles.Components.Profession do
  @moduledoc """
  The combatants profession
  """

  use Ecspanse.Component,
    state: [
      :name,
      :type
    ],
    tags: [:profession]

  def new(name, type) do
    {__MODULE__, name: name, type: type}
  end

  def new_pistolero() do
    new("Pistolero", :pistolero)
  end

  def new_machine_gunner() do
    new("Gunner", :machine_gunner)
  end

  def new_sniper() do
    new("Sniper", :sniper)
  end

  @impl true
  def validate(state) do
    validate_name(state.name)
  end

  defp validate_name("" = name),
    do: {:error, "Classes must have a name.  Provided: #{inspect(name)}"}

  defp validate_name(name) when is_nil(name),
    do: {:error, "Classes must have a name.  Provided: #{inspect(name)}"}

  defp validate_name(_), do: :ok
end
