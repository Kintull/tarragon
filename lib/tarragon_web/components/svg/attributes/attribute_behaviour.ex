defmodule TarragonWeb.Svg.Attributes.AttributeBehaviour do
  @moduledoc """
  Attributes implement this behaviour to ensure that they are valid
  """
  @callback is_valid?(struct()) :: true | {:error, String.t()}
  @callback to_html(struct()) :: list(tuple())
end
