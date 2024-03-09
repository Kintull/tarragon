defmodule Tarragon.Ecspanse.Withables do
  @moduledoc """
  Functions that make with returns more convenient
  E.g. fetch functions

  ## Example
  iex> a = 1
  iex> Withables.nil_not_found(a)
  {:ok, 1}

  iex> b = nil
  iex> Withables.nil_not_found(b)
  {:error, :not_found}
  """
  @spec nil_not_found(any()) :: {:error, :not_found} | {:ok, any()}
  @doc """
  Takes a value and returns with friendly tuples
  """
  def nil_not_found(val) do
    case val do
      nil -> {:error, :not_found}
      _ -> {:ok, val}
    end
  end

  @doc """
  takes a with tuple and returns the value when :ok or nil otherwise
  """
  def val_or_nil(tuple) do
    case tuple do
      {:ok, val} -> val
      _ -> nil
    end
  end

  @doc """
  takes a with tuple and returns the value when :ok or raises an error otherwise
  """
  def val_or_raise(tuple) do
    case tuple do
      {:ok, val} -> val
      err -> raise err
    end
  end
end
