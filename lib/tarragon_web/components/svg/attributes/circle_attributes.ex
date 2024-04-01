defmodule TarragonWeb.Svg.Attributes.CircleAttributes do
  @moduledoc """
    Circle Attributes

    the geometry properties of a circle.

    ## Fields
    + **cx** - Horizontal center coordinate
    + **cy** - Vertical center coordinate
    + **r** - the radius of the circle
  """

  @behaviour TarragonWeb.Svg.Attributes.AttributeBehaviour

  @enforce_keys [:cx, :cy, :r]
  defstruct cx: nil, cy: nil, r: nil

  @typedoc """
  Circle Attributes

    + **cx** - Horizontal center coordinate  + **cy** - Vertical center coordinate  + **r** - the radius of the circle
  """
  @type t :: %__MODULE__{
          cx: number(),
          cy: number(),
          r: number()
        }

  @impl true
  def is_valid?(%__MODULE__{} = attrs) do
    with true <- validate_cx(Map.get(attrs, :cx)),
         true <- validate_cy(Map.get(attrs, :cy)),
         true <- validate_r(Map.get(attrs, :r)) do
      true
    else
      err -> err
    end
  end

  @spec new(number(), number(), number(), keyword()) :: __MODULE__.t()
  def new(cx, cy, r, opts \\ []) do
    struct!(__MODULE__, cx: cx, cy: cy, r: r)
    |> struct!(opts)
  end

  @spec set_cx(__MODULE__.t(), number()) :: __MODULE__.t()
  def set_cx(attrs, cx) do
    Map.put(attrs, :cx, cx)
  end

  @spec set_cy(__MODULE__.t(), number()) :: __MODULE__.t()
  def set_cy(attrs, cy) do
    Map.put(attrs, :cy, cy)
  end

  @spec set_r(__MODULE__.t(), number()) :: __MODULE__.t()
  def set_r(attrs, r) do
    Map.put(attrs, :r, r)
  end

  @impl true
  def to_html(attrs) when is_nil(attrs) do
    []
  end

  def to_html(%__MODULE__{} = attrs) do
    [
      {"cx", attrs.cx},
      {"cy", attrs.cy},
      {"r", attrs.r}
    ]
  end

  @spec validate_cx(:float) :: true | {false, String.t()}
  defp validate_cx(_cx) do
    true
  end

  @spec validate_cy(:float) :: true | {false, String.t()}
  defp validate_cy(_cy) do
    true
  end

  @spec validate_r(:float) :: true | {false, String.t()}
  defp validate_r(_r) do
    true
  end
end
