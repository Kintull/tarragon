defmodule TarragonWeb.Svg.Types.LanguageTag do
  @type t() :: binary()
  defguard is_language_tag(value) when not is_nil(value) and length(value) > 0
end
