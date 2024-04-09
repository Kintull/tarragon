defmodule TarragonWeb.AdminLive.Index do
  @moduledoc """
  entry point to the admin portal
  weapon parameters
  battle room parameters
  profession parameters
  """
  use TarragonWeb, :live_view

  def mount(_params, %{}, socket) do
    {:ok, socket, layout: false}
  end

  def render(assigns) do
    ~H"""
    <div class="flex justify-center items-center h-full">
          <h1 class="text-4xl">Welcome to the Admin Portal</h1>
        </div>
    """
  end
end
