defmodule TarragonWeb.Svg.Attributes.PositionAttributes do
  @moduledoc """
    Position Attributes

    the location of an element.

    ## Fields
    + **x** - Horizontal left coordinate
    + **y** - Vertical top coordinate
  """

  @behaviour TarragonWeb.Svg.Attributes.AttributeBehaviour

  @enforce_keys [:x, :y]
  defstruct x: nil, y: nil

  @typedoc """
  Position Attributes

    + **x** - Horizontal left coordinate  + **y** - Vertical top coordinate
  """
  @type t :: %__MODULE__{
          x: :float,
          y: :float
        }

  @impl true
  def is_valid?(%__MODULE__{} = attrs) do
    with true <- validate_x(Map.get(attrs, :x)),
         true <- validate_y(Map.get(attrs, :y)) do
      true
    else
      err -> err
    end
  end

  @spec new(:float, :float, keyword()) :: __MODULE__.t()
  def new(x, y, opts \\ []) do
    struct!(__MODULE__, x: x, y: y)
    |> struct!(opts)
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
    [
      {"x", attrs.x},
      {"y", attrs.y}
    ]
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
