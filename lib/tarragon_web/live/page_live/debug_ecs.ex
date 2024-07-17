defmodule TarragonWeb.PageLive.DebugEcs do
  use TarragonWeb, :live_view

  def mount(_params, _session, socket) do
    ecs_entities = []
    {:ok, assign(socket, ecs_entities: ecs_entities)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Table with ECS Entities</h1>

      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>ID</th>
            <th>Components</th>
          </tr>
        </thead>
        <tbody>
          <%= for {name, id, components} <- @ecs_entities do %>
            <tr>
              <td><%= name %></td>
              <td><%= id %></td>
              <td><%= components %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
