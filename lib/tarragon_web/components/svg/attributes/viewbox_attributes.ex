defmodule TarragonWeb.Svg.Attributes.ViewboxAttributes do
  @moduledoc """
    Viewbox Attributes

    the position and dimensions of the svg's viewbox.

    ## Fields
    + **height** - The size of the horizontal axis
    + **width** - The size in the Vertical axis
    + **x** - Horizontal left coordinate
    + **y** - Vertical top coordinate
  """

  @behaviour TarragonWeb.Svg.Attributes.AttributeBehaviour

  @enforce_keys [:height, :width, :x, :y]
  defstruct height: nil, width: nil, x: nil, y: nil

  @typedoc """
  Viewbox Attributes

    + **height** - The size of the horizontal axis  + **width** - The size in the Vertical axis  + **x** - Horizontal left coordinate  + **y** - Vertical top coordinate
  """
  @type t :: %__MODULE__{
          height: :float,
          width: :float,
          x: :float,
          y: :float
        }

  @impl true
  def is_valid?(%__MODULE__{} = attrs) do
    with true <- validate_height(Map.get(attrs, :height)),
         true <- validate_width(Map.get(attrs, :width)),
         true <- validate_x(Map.get(attrs, :x)),
         true <- validate_y(Map.get(attrs, :y)) do
      true
    else
      err -> err
    end
  end

  @spec new(:float, :float, :float, :float, keyword()) :: __MODULE__.t()
  def new(x, y, width, height, opts \\ []) do
    struct!(__MODULE__, height: height, width: width, x: x, y: y)
    |> struct!(opts)
  end

  @spec set_height(__MODULE__.t(), :float) :: __MODULE__.t()
  def set_height(attrs, height) do
    Map.put(attrs, :height, height)
  end

  @spec set_width(__MODULE__.t(), :float) :: __MODULE__.t()
  def set_width(attrs, width) do
    Map.put(attrs, :width, width)
  end

  @spec set_x(__MODULE__.t(), :float) :: __MODULE__.t()
  def set_x(attrs, x) do
    Map.put(attrs, :x, x)
  end

  @spec set_y(__MODULE__.t(), :float) :: __MODULE__.t()
  def set_y(attrs, y) do
    Map.put(attrs, :y, y)
  end

  @impl true
  def to_html(attrs) when is_nil(attrs) do
    []
  end

  def to_html(%__MODULE__{} = attrs) do
    "#{attrs.x} #{attrs.y} #{attrs.width} #{attrs.height}"
  end

  @spec validate_height(:float) :: true | {false, String.t()}
  defp validate_height(_height) do
    true
  end

  @spec validate_width(:float) :: true | {false, String.t()}
  defp validate_width(_width) do
    true
  end

  @spec validate_x(:float) :: true | {false, String.t()}
  defp validate_x(_x) do
    true
  end

  @spec validate_y(:float) :: true | {false, String.t()}
  defp validate_y(_y) do
    true
  end
end
