defmodule TarragonWeb.Svg.Types.Id do
  @type id() :: binary()

  defguard is_id(value) when not is_nil(value) and length(value) > 0
end
