defmodule Tarragon.Ecspanse.Battles.Components.Brand do
  @moduledoc """

  """
  use Ecspanse.Component,
    state: [
      name: "",
      icon: "",
      color: "#0F0"
    ]

  @impl true
  def validate(component) do
    with :ok <- validate_name(component.name) do
      validate_color(component.color)
    end
  end

  defp validate_name("" = name),
    do: {:error, "Classes must have a name.  Provided: #{inspect(name)}"}

  defp validate_name(name) when is_nil(name),
    do: {:error, "Classes must have a name.  Provided: #{inspect(name)}"}

  defp validate_name(_), do: :ok

  defp validate_color("" = color),
    do: {:error, "Classes must have a color.  Provided: #{inspect(color)}"}

  defp validate_color(color) when is_nil(color),
    do: {:error, "Classes must have a color.  Provided: #{inspect(color)}"}

  defp validate_color(_), do: :ok
end
