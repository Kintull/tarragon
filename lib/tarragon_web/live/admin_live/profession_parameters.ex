defmodule TarragonWeb.AdminLive.ProfessionParameters do
  @moduledoc """
  Index page containing a table that lists available professions and their parameters in a form,
  allowing to update them in place.

  ProfessionParameters has
  name: string
  description: string
  hit_points: integer
  attack: integer
  defense: integer
  speed: integer

  """
  use TarragonWeb, :live_view

  def mount(_params, %{}, socket) do
    {:ok, socket, layout: false}
  end

  def render(assigns) do
    ~H"""
    <div class="flex-grow">
        <div class="flex justify-center items-center h-full">
          <h1 class="text-4xl">Welcome to the Admin Portal</h1>
        </div>
    </div>
    """
  end
end
