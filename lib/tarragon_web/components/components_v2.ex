defmodule TarragonWeb.ComponentsV2 do
  @moduledoc """
    Components that the user sees when she opens on the main game screen
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  import TarragonWeb.CoreComponents

  embed_templates "components_v2/**/*"
end
