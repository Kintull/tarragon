defmodule Tarragon.Ecspanse.Battles.Components.Professions.Template do
  @moduledoc """
  the template for any form of movement
  """

  use Ecspanse.Template.Component,
    state: [
      :name,
      :type,
      :image_url,
      icon: "?"
    ],
    tags: [:profession]

  @impl true
  def validate(state) do
    validate_name(state[:name])
  end

  defp validate_name("" = name),
    do: {:error, "Classes must have a name.  Provided: #{inspect(name)}"}

  defp validate_name(name) when is_nil(name),
    do: {:error, "Classes must have a name.  Provided: #{inspect(name)}"}

  defp validate_name(_), do: :ok
end
