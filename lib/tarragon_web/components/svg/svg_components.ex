defmodule TarragonWeb.Svg.SvgComponents do
  @moduledoc """
  components for rendering svg
  """

  alias TarragonWeb.Svg.Attributes.CircleAttributes
  alias TarragonWeb.Svg.Attributes.CoreAttributes
  alias TarragonWeb.Svg.Attributes.DimensionAttributes
  alias TarragonWeb.Svg.Attributes.FillAttributes
  alias TarragonWeb.Svg.Attributes.PositionAttributes
  alias TarragonWeb.Svg.Attributes.RoundedCornerAttributes
  alias TarragonWeb.Svg.Attributes.StartEndAttributes
  alias TarragonWeb.Svg.Attributes.StrokeAttributes
  alias TarragonWeb.Svg.Attributes.ViewboxAttributes

  use Phoenix.Component

  attr :circle, CircleAttributes
  attr :fill, FillAttributes
  attr :stroke, StrokeAttributes

  @doc """
  The <circle> element is used to create a circle.
  """

  def circle(assigns) do
    ~H"""
    <circle
      {CircleAttributes.to_html(assigns[:circle])}
      {FillAttributes.to_html(assigns[:fill])}
      {StrokeAttributes.to_html(assigns[:stroke])}
    />
    """
  end

  attr :core, CoreAttributes
  slot :inner_block

  def defs(assigns) do
    ~H"""
    <defs {CoreAttributes.to_html(assigns[:core])}>
      <%= render_slot(@inner_block) %>
    </defs>
    """
  end

  attr :core, CoreAttributes
  slot :inner_block

  def g(assigns) do
    ~H"""
    <g{CoreAttributes.to_html(assigns[:core])}>
      <%= render_slot(@inner_block) %>
    </g{CoreAttributes.to_html(assigns[:core])}>
    """
  end

  @doc """
  defines a line segment that starts at one point and ends at another.
  """

  def line(assigns) do
    ~H"""
    <line
      {StartEndAttributes.to_html(assigns[:start_end])}
      {StrokeAttributes.to_html(assigns[:stroke])}
    />
    """
  end

  attr :id, :string, required: true
  attr :x1, :float, default: 0.0
  attr :y1, :float, default: 0.0
  attr :x2, :float, default: 100.0
  attr :y2, :float, default: 100.0
  attr :stroke, StrokeAttributes

  slot :stop, required: true do
    attr :offset, :float, required: true
    attr :color, :string, required: true
  end

  @doc """
  defines a linear gradient.
  """

  def linear_gradient(assigns) do
    ~H"""
    <linearGradient
      id={@id}
      x1={as_percent(@x1)}
      y={as_percent(@y1)}
      x={as_percent(@x2)}
      y2={as_percent(@y2)}
      {StrokeAttributes.to_html(assigns[:stroke])}
    >
      <stop
        :for={stop <- Enum.sort_by(@stop, & &1.offset)}
        offset={"#{stop[:offset]}%"}
        stop-color={stop[:color]}
      />
    </linearGradient>
    """
  end

  defp as_percent(value) when is_nil(value), do: nil
  defp as_percent(value), do: "#{value}%"

  attr :core, CoreAttributes
  attr :dimensions, DimensionAttributes
  attr :viewbox, ViewboxAttributes, required: true
  slot :inner_block

  @doc """
  An SVG document fragment consists of any number of SVG elements
  """
  def svg(assigns) do
    ~H"""
    <svg
      {CoreAttributes.to_html(assigns[:core])}
      {DimensionAttributes.to_html(assigns[:dimensions])}
      viewBox={ViewboxAttributes.to_html(assigns[:viewbox])}
    >
      <%= render_slot(@inner_block) %>
    </svg>
    """
  end

  attr :position, PositionAttributes, default: PositionAttributes.new(0.0, 0.0)
  attr :dimensions, DimensionAttributes
  attr :fill, FillAttributes
  attr :stroke, StrokeAttributes
  attr :rounded_corners, RoundedCornerAttributes

  @doc """
  The <rect> element is used to create a rectangle and variations of a rectangle shape
  """

  def rect(assigns) do
    ~H"""
    <rect
      {PositionAttributes.to_html(assigns[:position])}
      {DimensionAttributes.to_html(assigns[:dimensions])}
      {RoundedCornerAttributes.to_html(assigns[:rounded_corners])}
      {FillAttributes.to_html(assigns[:fill])}
      {StrokeAttributes.to_html(assigns[:stroke])}
    />
    """
  end
end
