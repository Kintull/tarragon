defmodule Tarragon.EcsxMacros do
  defp defguard_is_name(name), do: String.to_atom("is_#{Atom.to_string(name)}?")

  defp for_atom(atom) do
    quote do
      def unquote(atom)(), do: unquote(atom)
      defguard unquote(defguard_is_name(atom))(val) when val == unquote(atom)
    end
  end

  defp for_list(atoms, collection_name) do
    quote do
      defguard unquote(defguard_is_name(collection_name))(val) when val in unquote(atoms)
    end
  end

  defmacro getter_and_guard(atom) when is_atom(atom), do: for_atom(atom)

  @doc """
  creates a guard for the collection, a guard for each atom, and a 'get' function for each atom.

  ## Examples
    getters_and_guards([:foo, :bar, :baz])

    defguard is_valid(val) when val in [:foo, :bar, :baz]
    defguard is_foo(val) when val == :foo
    defguard is_bar(val) when val == :bar
    defguard is_baz(val) when val == :baz

    def foo(), do: :foo
    def bar(), do: :bar
    def baz(), do: :baz

  """
  defmacro getters_and_guards(atoms, collection_name \\ :valid_state)
           when is_list(atoms) and length(atoms) > 0 do
    list = for_list(atoms, collection_name)

    individuals =
      Enum.map(atoms, fn atom ->
        for_atom(atom)
      end)

    [list, individuals]
  end

  defmacro __using__(_opts) do
    quote do
      import Tarragon.EcsxMacros
    end
  end
end
