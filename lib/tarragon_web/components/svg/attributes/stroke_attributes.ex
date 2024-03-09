defmodule TarragonWeb.Svg.Attributes.StrokeAttributes do
  @moduledoc """
    Stroke Attributes

    properties that control different aspects of a stroke, including its paint, thickness, use of dashing, and joining and capping of path segments.

    ## Fields
    + **color** - sets the color of the line around an element.
    + **dash_array** - sets the pattern of dashes and gaps used to stroke paths.
    + **linecap** - sets the shape of the end-lines for a line or open path.
    + **linejoin** - sets the shape used to join two or more line segments where they meet.
    + **opacity** - sets the transparency of the line around an element.
    + **width** - sets the width of the line around an element. Default: 1
  """

  @behaviour TarragonWeb.Svg.Attributes.AttributeBehaviour

  @enforce_keys [:color]
  defstruct color: nil, dash_array: nil, linecap: nil, linejoin: nil, opacity: nil, width: 1

  @typedoc """
  Stroke Attributes

    + **color** - sets the color of the line around an element.  + **dash_array** - sets the pattern of dashes and gaps used to stroke paths.  + **linecap** - sets the shape of the end-lines for a line or open path.  + **linejoin** - sets the shape used to join two or more line segments where they meet.  + **opacity** - sets the transparency of the line around an element.  + **width** - sets the width of the line around an element. Default: 1
  """
  @type t :: %__MODULE__{
          color: String.t(),
          dash_array: String.t(),
          linecap: :float,
          linejoin: String.t(),
          opacity: :float,
          width: :float
        }

  @impl true
  def is_valid?(%__MODULE__{} = attrs) do
    with true <- validate_color(Map.get(attrs, :color)),
         true <- validate_dash_array(Map.get(attrs, :dash_array)),
         true <- validate_linecap(Map.get(attrs, :linecap)),
         true <- validate_linejoin(Map.get(attrs, :linejoin)),
         true <- validate_opacity(Map.get(attrs, :opacity)),
         true <- validate_width(Map.get(attrs, :width)) do
      true
    else
      err -> err
    end
  end

  @spec new(String.t(), keyword()) :: __MODULE__.t()
  def new(color, opts \\ []) do
    struct!(__MODULE__,
      color: color
    )
    |> struct!(opts)
  end

  @spec set_color(__MODULE__.t(), :binary) :: __MODULE__.t()
  def set_color(attrs, color) do
    Map.put(attrs, :color, color)
  end

  @spec set_dash_array(__MODULE__.t(), :binary) :: __MODULE__.t()
  def set_dash_array(attrs, dash_array) do
    Map.put(attrs, :dash_array, dash_array)
  end

  @spec set_linecap(__MODULE__.t(), :float) :: __MODULE__.t()
  def set_linecap(attrs, linecap) do
    Map.put(attrs, :linecap, linecap)
  end

  @spec set_linejoin(__MODULE__.t(), :binary) :: __MODULE__.t()
  def set_linejoin(attrs, linejoin) do
    Map.put(attrs, :linejoin, linejoin)
  end

  @spec set_opacity(__MODULE__.t(), :float) :: __MODULE__.t()
  def set_opacity(attrs, opacity) do
    Map.put(attrs, :opacity, opacity)
  end

  @spec set_width(__MODULE__.t(), :float) :: __MODULE__.t()
  def set_width(attrs, width) do
    Map.put(attrs, :width, width)
  end

  @impl true
  def to_html(attrs) when is_nil(attrs) do
    []
  end

  def to_html(%__MODULE__{} = attrs) do
    [
      {"stroke", attrs.color},
      {"stroke-dasharray", attrs.dash_array},
      {"stroke-linecap", attrs.linecap},
      {"stroke-linejoin", attrs.linejoin},
      {"stroke-opacity", attrs.opacity},
      {"stroke-width", attrs.width}
    ]
  end

  @spec validate_color(:binary) :: true | {false, String.t()}
  defp validate_color(_color) do
    true
  end

  @spec validate_dash_array(:binary) :: true | {false, String.t()}
  defp validate_dash_array(_dash_array) do
    true
  end

  @spec validate_linecap(:float) :: true | {false, String.t()}
  defp validate_linecap(_linecap) do
    true
  end

  @spec validate_linejoin(:binary) :: true | {false, String.t()}
  defp validate_linejoin(_linejoin) do
    true
  end

  @spec validate_opacity(:float) :: true | {false, String.t()}
  defp validate_opacity(_opacity) do
    true
  end

  @spec validate_width(:float) :: true | {false, String.t()}
  defp validate_width(_width) do
    true
  end
end
