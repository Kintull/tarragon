defmodule Tarragon.Ecspanse.Battles.Components.Utils do
  @spec to_component_spec(Ecspanse.Component.t()) :: Ecspanse.Component.component_spec()
  @doc """
  returns a component spec for the given component.  this is useful when trying to clone
  """
  def to_component_spec(component) do
    %component_module{} = component

    data = component |> Map.from_struct() |> Map.delete(:__meta__) |> Map.to_list()
    # data =
    #   Map.to_list(component)
    #   |> Enum.reject(
    #     &(elem(&1, 0)
    #       |> Atom.to_string()
    #       |> String.starts_with?("__"))
    #   )

    {component_module, data}
  end
end
