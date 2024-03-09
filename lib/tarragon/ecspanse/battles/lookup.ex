defmodule Tarragon.Ecspanse.Battles.Lookup do
  @moduledoc """
  Convenience functions for fetching ancestors, parents, descendants, and children
  """
  alias Tarragon.Ecspanse.Withables

  @spec fetch_ancestor(Ecspanse.Entity.t(), module()) ::
          {:ok, Ecspanse.Entity.t()} | {:error, :not_found}
  @doc """
  Returns the first ancestor with the ancestor_component
  """
  def fetch_ancestor(entity, ancestor_component) do
    Ecspanse.Query.list_ancestors(entity)
    |> Enum.find(&Ecspanse.Query.has_component?(&1, ancestor_component))
    |> Withables.nil_not_found()
  end

  @spec fetch_child(Ecspanse.Entity.t(), module()) ::
          {:ok, Ecspanse.Entity.t()} | {:error, :not_found}
  @doc """
  Returns the first child with the child_component
  """
  def fetch_child(entity, child_component) do
    Ecspanse.Query.list_children(entity)
    |> Enum.find(&Ecspanse.Query.has_component?(&1, child_component))
    |> Withables.nil_not_found()
  end

  @spec fetch_descendant(Ecspanse.Entity.t(), module()) ::
          {:ok, Ecspanse.Entity.t()} | {:error, :not_found}
  @doc """
  Returns the first descendant with the descendant_component
  """
  def fetch_descendant(entity, descendant_component) do
    Ecspanse.Query.list_descendants(entity)
    |> Enum.find(&Ecspanse.Query.has_component?(&1, descendant_component))
    |> Withables.nil_not_found()
  end

  @spec fetch_parent(Ecspanse.Entity.t(), module()) ::
          {:ok, Ecspanse.Entity.t()} | {:error, :not_found}
  @doc """
  Returns the first parent with the parent_component
  """
  def fetch_parent(entity, parent_component) do
    Ecspanse.Query.list_parents(entity)
    |> Enum.find(&Ecspanse.Query.has_component?(&1, parent_component))
    |> Withables.nil_not_found()
  end

  @spec list_ancestors(Ecspanse.Entity.t(), module()) :: list(Ecspanse.Entity.t())
  @doc """
  Returns ancestors with the ancestor_component
  """
  def list_ancestors(entity, ancestor_component) do
    Ecspanse.Query.list_ancestors(entity)
    |> Enum.filter(&Ecspanse.Query.has_component?(&1, ancestor_component))
  end

  @spec list_children(Ecspanse.Entity.t(), module()) :: list(Ecspanse.Entity.t())
  @doc """
  Returns children with the child_component
  """
  def list_children(entity, child_component) do
    Ecspanse.Query.list_children(entity)
    |> Enum.filter(&Ecspanse.Query.has_component?(&1, child_component))
  end

  @spec list_descendants(Ecspanse.Entity.t(), module()) :: list(Ecspanse.Entity.t())
  @doc """
  Returns descendants with the descendant_component
  """
  def list_descendants(entity, descendant_component) do
    Ecspanse.Query.list_descendants(entity)
    |> Enum.filter(&Ecspanse.Query.has_component?(&1, descendant_component))
  end

  @spec list_parents(Ecspanse.Entity.t(), module()) :: list(Ecspanse.Entity.t())
  @doc """
  Returns parents with the parent_component
  """
  def list_parents(entity, parent_component) do
    Ecspanse.Query.list_parents(entity)
    |> Enum.filter(&Ecspanse.Query.has_component?(&1, parent_component))
  end
end
