defmodule Tarragon do
  @moduledoc """
  Tarragon keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  defmacro aliases(expression) do
    {:ok, modules} = :application.get_key(:tarragon, :modules)

    modules =
      for module <- modules do
        quote do
          alias unquote(module)
        end
      end

    quote do
      unquote(modules)
      unquote(expression)
    end
  end

  #
  #  require Tarragon
  #  Tarragon.aliases(1+1)
end
