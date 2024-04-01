defmodule TarragonWeb.Svg.Attributes.StartEndAttributes do
  @moduledoc """
    Start End Attributes

    the start and end positions.

    ## Fields
    + **x1** - Starting horizontal coordinate
    + **x2** - Ending horizontal coordinate
    + **y1** - Starting vertical coordinate
    + **y2** - Ending vertical coordinate
  """

  @behaviour TarragonWeb.Svg.Attributes.AttributeBehaviour

  @enforce_keys [:x1, :x2, :y1, :y2]
  defstruct x1: nil, x2: nil, y1: nil, y2: nil

  @typedoc """
  Start End Attributes

    + **x1** - Starting horizontal coordinate  + **x2** - Ending horizontal coordinate  + **y1** - Starting vertical coordinate  + **y2** - Ending vertical coordinate
  """
  @type t :: %__MODULE__{
          x1: number(),
          x2: number(),
          y1: number(),
          y2: number()
        }

  @impl true
  def is_valid?(%__MODULE__{} = attrs) do
    with true <- validate_x1(Map.get(attrs, :x1)),
         true <- validate_x2(Map.get(attrs, :x2)),
         true <- validate_y1(Map.get(attrs, :y1)),
         true <- validate_y2(Map.get(attrs, :y2)) do
      true
    else
      err -> err
    end
  end

  @spec new(number(), number(), number(), number(), keyword()) :: __MODULE__.t()
  def new(x1, y1, x2, y2, opts \\ []) do
    struct!(__MODULE__, x1: x1, x2: x2, y1: y1, y2: y2)
    |> struct!(opts)
  end

  @spec set_x1(__MODULE__.t(), :float) :: __MODULE__.t()
  def set_x1(attrs, x1) do
    Map.put(attrs, :x1, x1)
  end

  @spec set_x2(__MODULE__.t(), :float) :: __MODULE__.t()
  def set_x2(attrs, x2) do
    Map.put(attrs, :x2, x2)
  end

  @spec set_y1(__MODULE__.t(), :float) :: __MODULE__.t()
  def set_y1(attrs, y1) do
    Map.put(attrs, :y1, y1)
  end

  @spec set_y2(__MODULE__.t(), :float) :: __MODULE__.t()
  def set_y2(attrs, y2) do
    Map.put(attrs, :y2, y2)
  end

  @impl true
  def to_html(attrs) when is_nil(attrs) do
    []
  end

  def to_html(%__MODULE__{} = attrs) do
    [
      {"x1", attrs.x1},
      {"x2", attrs.x2},
      {"y1", attrs.y1},
      {"y2", attrs.y2}
    ]
  end

  @spec validate_x1(:float) :: true | {false, String.t()}
  defp validate_x1(_x1) do
    true
  end

  @spec validate_x2(:float) :: true | {false, String.t()}
  defp validate_x2(_x2) do
    true
  end

  @spec validate_y1(:float) :: true | {false, String.t()}
  defp validate_y1(_y1) do
    true
  end

  @spec validate_y2(:float) :: true | {false, String.t()}
  defp validate_y2(_y2) do
    true
  end
end
