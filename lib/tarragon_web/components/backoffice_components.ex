defmodule TarragonWeb.BackofficeComponents do
  @moduledoc """
    Components that the user sees when she opens on the main game screen
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  embed_templates "backoffice_components/**/*"
end
