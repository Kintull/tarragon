defmodule Tarragon.Ecspanse.MapUtils do
  @moduledoc """
  Utilities to create maps without ECS internals
  """

  @doc """
  Takes an entity struct, i.e. a map whose values are components,
  and returns a map with the Ecspanse internals removed
  """
  def project(%{} = map) do
    map
    |> Map.keys()
    |> Enum.reject(&is_ecspanse_internal?/1)
    # |> IO.inspect(label: "public keys")
    |> Enum.into(%{}, fn key ->
      {key, project(Map.get(map, key))}
    end)

    # |> IO.inspect(label: "filtered")
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
