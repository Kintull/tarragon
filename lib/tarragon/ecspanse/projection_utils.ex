defmodule Tarragon.Ecspanse.ProjectionUtils do
  @moduledoc """
  Utilities to create maps without ECS internals
  """

  def project_timer(map) do
    map
    |> Map.keys()
    |> Enum.reject(&is_ecspanse_internal?/1)
    |> Enum.into(%{}, fn key ->
      if key == :time do
        {key, ceil(Map.get(map, key) / 1000.0) * 1000.0}
      else
        {key, project(Map.get(map, key))}
      end
    end)

    # |> IO.inspect(label: "projected timer")
  end

  def project_generic_map(map) do
    map
    |> Map.keys()
    |> Enum.reject(&is_ecspanse_internal?/1)
    |> Enum.into(%{}, fn key ->
      {key, project(Map.get(map, key))}
    end)
  end

  # @doc """
  # Takes an entity struct, i.e. a map whose values are components,
  # and returns a map with the Ecspanse internals removed
  # """
  def project(%{} = map) when is_map(map) do
    is_timer =
      Map.get(map, :__meta__, %{}) |> Map.get(:tags, MapSet.new()) |> MapSet.member?(:ecs_timer)

    if is_timer do
      project_timer(map)
    else
      project_generic_map(map)
    end
  end

  def project(list) when is_list(list) do
    list |> Enum.map(&project/1)
  end

  def project(val), do: val

  defp is_ecspanse_internal?(:__meta__), do: true

  defp is_ecspanse_internal?(key) when is_atom(key),
    do: is_ecspanse_internal?(Atom.to_string(key))

  defp is_ecspanse_internal?(key) when is_binary(key), do: String.starts_with?(key, "_")
  defp is_ecspanse_internal?(_key), do: false
end
