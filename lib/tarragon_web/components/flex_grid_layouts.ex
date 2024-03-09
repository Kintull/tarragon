defmodule TarragonWeb.FlexGridLayouts do
  @moduledoc """
  Kevin Powell's Useful & Responsive Layouts, no Media Queries required
  https://www.youtube.com/watch?v=p3_xN2Zp1TY
  """

  use Phoenix.Component

  @doc """
  FlexWrap creates a horizontal flow of children that will wrap.
  Children will retain their own widths.
  Kevin Powell calls this a cluster or flex group.
  """
  slot :inner_block,
    required: true,
    doc: "the content to be arranged in the group.  Ideal for tags."

  attr :gap, :string,
    default: "1rem",
    doc: "specifies the size of the gap between items both horizontally and vertically."

  def flex_wrap(assigns) do
    ~H"""
    <div class="flex flex-wrap items-start" style={"gap: #{@gap};"}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
    AutoGrid Creates a horizontal flow of children that will wrap.  Each child is the same width.
  """
  slot :inner_block, required: true, doc: "the content to be arranged in the grid"

  attr :gap, :string,
    default: "1rem",
    doc: "specifies the size of the gap between items both horizontally and vertically."

  attr :min_column_size, :string,
    default: "10rem",
    doc: "specifies the minimum width of each item."

  def auto_grid(assigns) do
    ~H"""
    <div
      class="grid"
      style={[
        "gap: #{@gap};",
        "grid-template-columns: repeat(auto-fit, minmax(min(#{@min_column_size}, 100%), 1fr));"
      ]}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
    Creates a content section on the left with a sidebar on the right.
    The sidebar will drop below the content when the screen width is too narrow.

    ## Examples

      <LayoutComponents.content_with_right_sidebar>
        Anything here will go in the content pane on the left
        <:sidebar>
          This will go into the sidebar on the right
        </:sidebar>
      </LayoutComponents.content_with_right_sidebar>
  """
  slot :inner_block, required: true
  slot :sidebar, required: false
  attr :gap, :string, default: "1rem"
  attr :content_flex_basis, :string, default: "250px"
  attr :sidebar_flex_basis, :string, default: "150px"

  def content_with_right_sidebar(assigns) do
    ~H"""
    <div class="flex flex-wrap items-start" style={"gap: #{@gap};"}>
      <div style={"flex-grow: 9999; flex-basis: #{@content_flex_basis};"}>
        <%= render_slot(@inner_block) %>
      </div>

      <div class="flex-grow" style={"flex-basis: #{@sidebar_flex_basis};"}>
        <%= render_slot(@sidebar) %>
      </div>
    </div>
    """
  end

  @doc """
    Creates a horizontal flow of children that will wrap.  Each child is the same width.

    ## Examples

      <LayoutComponents.reel>
        <:reel_item :for={x <- 1..21}>
          <div style="border: 3px solid black;"><%= x %></div>
        </:reel_item>
      </LayoutComponents.reel>
  """
  slot :reel_item, required: true, doc: "Include one or more children in :reel_item tags"
  attr :gap, :string, default: "1rem"

  def reel(assigns) do
    ~H"""
    <div
      class="grid grid-flow-col overflow-x-scroll snap-x snap-mandatory"
      style={"scroll-padding: #{@gap};
    gap: #{@gap};
    grid-auto-columns: calc(30% - #{@gap} / 2);"}
    >
      <%= for ri <- @reel_item do %>
        <div style="scroll-snap-align: start;">
          <%= render_slot(ri) %>
        </div>
      <% end %>
    </div>
    """
  end
end
