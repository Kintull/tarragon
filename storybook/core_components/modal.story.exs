defmodule Storybook.CoreComponents.Modal do
  use PhoenixStorybook.Story, :component
  alias Elixir.TarragonWeb.CoreComponents

  def function, do: &CoreComponents.modal/1
  def imports, do: [{CoreComponents, [button: 1, hide_modal: 1, show_modal: 1]}]

  def template do
    """
    <.button phx-click={show_modal(":variation_id")} lsb-code-hidden>
      Open modal
    </.button>
    <.lsb-variation/>
    """
  end

  def variations do
    [
      %Variation{
        id: :default,
        slots: ["Modal body"]
      }
    ]
  end
end
