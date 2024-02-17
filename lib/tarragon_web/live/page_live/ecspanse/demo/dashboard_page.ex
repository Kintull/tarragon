defmodule TarragonWeb.PageLive.Ecspanse.Demo.DashboardPage do
  @moduledoc false
  alias Phoenix.LiveDashboard.PageBuilder
  use Phoenix.LiveDashboard.PageBuilder

  @base_tabs [:summary, :systems, :components, :events]

  defp assign_fps_data(socket) do
    {:ok, resource} =
      Ecspanse.Query.fetch_resource(Ecspanse.Resource.FPS)

    socket
    |> assign(:fps, Map.take(resource, [:current, :value, :millisecond]))
  end

  defp assign_tab_data(socket, :components) do
    socket
  end

  defp assign_tab_data(socket, :events) do
    socket
  end

  defp assign_tab_data(socket, :systems) do
    socket
  end

  defp assign_tab_data(socket, :summary) do
    assign_fps_data(socket)
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket =
      case params["nav"] do
        nil ->
          assign(socket,
            selector: "summary",
            component_type: nil,
            component_table: [],
            tabs: @base_tabs
          )

        "component" ->
          if type = params["type"] do
            component_type =
              socket.assigns.components
              |> Map.keys()
              |> Enum.find(fn full_type -> get_alias(full_type) == type end)

            socket
            |> assign(selector: params["nav"], component_type: component_type)
            |> assign(tabs: @base_tabs ++ [:component])

            # |> assign_component_table()
          else
            path =
              live_dashboard_path(socket, socket.assigns.page,
                nav: :component,
                type: get_alias(socket.assigns.component_type)
              )

            push_patch(socket, to: path)
          end

        nav when nav in ["components", "events", "systems", "summary"] ->
          assign(socket,
            selector: nav,
            component_type: nil,
            component_table: [],
            tabs: @base_tabs
          )
      end

    {:noreply, socket}
  end

  @impl true
  def handle_refresh(socket) do
    case socket.assigns.selector do
      "components" ->
        {:noreply, assign_tab_data(socket, :components)}

      "events" ->
        {:noreply, assign_tab_data(socket, :events)}

      "summary" ->
        {:noreply, assign_tab_data(socket, :summary)}

      "systems" ->
        {:noreply, assign_tab_data(socket, :systems)}
        # "component" -> {:noreply, assign_component_table(socket)}
    end
  end

  @impl true
  def menu_link(_, _) do
    {:ok, "Escpanse"}
  end

  @impl true
  def mount(params, _session, socket) do
    case params["nav"] do
      nil ->
        to = live_dashboard_path(socket, socket.assigns.page, nav: :summary)
        {:ok, push_navigate(socket, to: to)}

      nav ->
        socket =
          socket
          |> assign_tab_data(:components)
          |> assign_tab_data(:events)
          |> assign_tab_data(:systems)
          |> assign_tab_data(:summary)
          |> assign(
            selector: nav,
            tabs: @base_tabs,
            component_type: nil,
            component_table: []
          )

        {:ok, socket}
    end
  end

  defp format_nav_name(:summary), do: "Summary"
  defp format_nav_name(:systems), do: "Systems"
  defp format_nav_name(:components), do: "Components"
  defp format_nav_name(:component), do: "Component"
  defp format_nav_name(:events), do: "Events"

  defp get_alias(module) when is_atom(module) do
    module
    |> Module.split()
    |> List.last()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.live_nav_bar id="ecspanse_nav_bar" page={@page}>
      <:item :for={tab <- @tabs} name={to_string(tab)} label={format_nav_name(tab)} method="patch">
        <div></div>
      </:item>
    </.live_nav_bar>

    <div style="display: flex; flex-direction: column; align-items: center;">
      <%= case @selector do %>
        <% "summary" -> %>
          <.summary_tab fps={@fps} />
        <% "systems" -> %>
          systems
        <% "components" -> %>
          components
        <% "events" -> %>
          events
      <% end %>
    </div>
    """
  end

  def summary_tab(assigns) do
    ~H"""
    <PageBuilder.row>
      <:col>
        <.card title="FPS" hint="The Frames Per Second measured over the previous second.">
          <%= @fps.value %>
        </.card>
      </:col>
    </PageBuilder.row>
    """
  end
end
