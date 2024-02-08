defmodule Tarragon.Systems.SystemHelpers do
  @moduledoc """
  Convenience methods for Components
  """

  alias ECSx.Component
  alias ECSx.Tag

  @type component_or_tag :: Component.t() | Tag.t()
  @type entity_value_tuple :: {Component.id(), any()}
  @type entity_or_ev_tuple :: Component.id() | entity_value_tuple()

  @spec add_new(Component.id(), Tag.t()) :: :ok
  def add_new(entity, tag) do
    unless tag.exists?(entity), do: tag.add(entity), else: :ok
  end

  @spec upsert(Component.id(), Component.t(), Component.value(), Keyword.t()) ::
          :ok
  def upsert(entity, component, value, add_opts \\ []) do
    if component.exists?(entity) do
      component.update(entity, value)
    else
      component.add(entity, value, add_opts)
    end
  end

  @spec remove_components(Component.id(), list(component_or_tag())) :: :ok
  def remove_components(entity, components_and_tags) do
    Enum.each(components_and_tags, & &1.remove(entity))
  end

  defp do_entity_has?({entity, _value}, component_or_tag),
    do: do_entity_has?(entity, component_or_tag)

  defp do_entity_has?(entity, component_or_tag), do: component_or_tag.exists?(entity)

  @spec entity_has?(entity_or_ev_tuple(), component_or_tag()) :: boolean
  def entity_has?(entity_or_ev_tuple, component_or_tag) do
    do_entity_has?(entity_or_ev_tuple, component_or_tag)
  end

  @spec where_entity_has(list(entity_or_ev_tuple()), component_or_tag()) ::
          list(entity_or_ev_tuple())
  def where_entity_has(entities_or_entity_value_tuples, required_component_or_tag) do
    Enum.filter(
      entities_or_entity_value_tuples,
      &do_entity_has?(&1, required_component_or_tag)
    )
  end

  defp do_entity_is_missing?({entity, _value}, component_or_tag),
    do: do_entity_is_missing?(entity, component_or_tag)

  defp do_entity_is_missing?(entity, component_or_tag), do: not component_or_tag.exists?(entity)

  @spec entity_is_missing?(entity_or_ev_tuple(), component_or_tag()) :: boolean
  def entity_is_missing?(entity_or_ev_tuple, component_or_tag),
    do: do_entity_is_missing?(entity_or_ev_tuple, component_or_tag)

  @spec where_entity_is_missing(list(entity_or_ev_tuple()), component_or_tag()) ::
          list(entity_or_ev_tuple())
  def where_entity_is_missing(entities_or_entity_value_tuples, component_or_tag) do
    Enum.filter(
      entities_or_entity_value_tuples,
      &do_entity_is_missing?(&1, component_or_tag)
    )
  end

  @spec is_before?({Component.id(), DateTime.t()}, DateTime.t()) :: boolean()
  def is_before?({_entity, dt}, cutoff) when is_struct(dt, DateTime),
    do: DateTime.before?(dt, cutoff)

  @spec when_is_before(list({Component.id(), DateTime.t()}), DateTime.t()) ::
          list({Component.id(), DateTime.t()})
  def when_is_before(entity_datetime_tuples, cutoff) do
    Enum.filter(entity_datetime_tuples, &is_before?(&1, cutoff))
  end

  @doc """
  This will IO.inspect the length of a list.  It's useful in piped operations to know when the list is being filtered down.
  """
  def inspect_length(list, label) when is_list(list) do
    IO.inspect(length(list), label: label)
    list
  end
end
