defmodule Tarragon.TakeDamageOverTime do
  require Tarragon.EcsxMacros
  import Tarragon.EcsxMacros

  getters_and_guards([:foo, :bar, :baz], :my_states)
  # Tarragon.EcsxMacros.getter_and_guard(:foo)
  # Tarragon.EcsxMacros.getter_and_guard(:bar)

  def say(val) when is_foo?(val), do: "Guard confirmed you said #{foo()}"
  def say(val) when is_bar?(val), do: "Guard confirmed you said #{bar()}"
  def say(_val), do: false

  def valid?(val) when is_my_states?(val), do: "is_my_states Guard says #{val} is valid"
  def valid?(val), do: "is_my_states guard rejected #{val}"

  # Tarragon.MyModule.__info__(:functions)
end
