defmodule TarragonWeb.Svg.Attributes.FillAttributes do
  @moduledoc """
    Fill Attributes

    properties that control different aspects of a fill.

    ## Fields
    + **color** - sets the color of the fill of the  element.
    + **opacity** - sets the transparency of the fill of the element.
    + **rule** - sets the algorithm used to determine the inside part of the shape
  """

  @behaviour TarragonWeb.Svg.Attributes.AttributeBehaviour

  @enforce_keys [:color]
  defstruct color: nil, opacity: nil, rule: nil

  @typedoc """
  Fill Attributes

    + **color** - sets the color of the fill of the  element.  + **opacity** - sets the transparency of the fill of the element.  + **rule** - sets the algorithm used to determine the inside part of the shape
  """
  @type t :: %__MODULE__{
          color: String.t(),
          opacity: number(),
          rule: :nonzero | :evenodd
        }

  @impl true
  def is_valid?(%__MODULE__{} = attrs) do
    with true <- validate_color(Map.get(attrs, :color)),
         true <- validate_opacity(Map.get(attrs, :opacity)),
         true <- validate_rule(Map.get(attrs, :rule)) do
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

  @spec set_color(__MODULE__.t(), String.t()) :: __MODULE__.t()
  def set_color(attrs, color) do
    Map.put(attrs, :color, color)
  end

  @spec set_opacity(__MODULE__.t(), number()) :: __MODULE__.t()
  def set_opacity(attrs, opacity) do
    Map.put(attrs, :opacity, opacity)
  end

  @spec set_rule(__MODULE__.t(), :nonzero | :evenodd) :: __MODULE__.t()
  def set_rule(attrs, rule) do
    Map.put(attrs, :rule, rule)
  end

  @impl true
  def to_html(attrs) when is_nil(attrs) do
    []
  end

  def to_html(%__MODULE__{} = attrs) do
    [
      {"fill", attrs.color},
      {"fill-opacity", attrs.opacity},
      {"fill-rule", attrs.rule}
    ]
  end

  @spec validate_color(String.t()) :: true | {false, String.t()}
  defp validate_color(_color) do
    true
  end

  @spec validate_opacity(number()) :: true | {false, String.t()}
  defp validate_opacity(_opacity) do
    true
  end

  @spec validate_rule(:nonzero | :evenodd) :: true | {false, String.t()}
  defp validate_rule(_rule) do
    true
  end
end
