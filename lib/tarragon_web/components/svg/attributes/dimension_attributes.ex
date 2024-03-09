defmodule TarragonWeb.Svg.Attributes.DimensionAttributes do
  @moduledoc """
    Dimension Attributes

    The height and width of a shape

    ## Fields
    + **height** - The size of the horizontal axis
    + **width** - The size in the Vertical axis
  """

  @behaviour TarragonWeb.Svg.Attributes.AttributeBehaviour

  @enforce_keys [:height, :width]
  defstruct height: nil, width: nil

  @typedoc """
  Dimension Attributes

    + **height** - The size of the horizontal axis  + **width** - The size in the Vertical axis
  """
  @type t :: %__MODULE__{
          height: :float,
          width: :float
        }

  @impl true
  def is_valid?(%__MODULE__{} = attrs) do
    with true <- validate_height(Map.get(attrs, :height)),
         true <- validate_width(Map.get(attrs, :width)) do
      true
    else
      err -> err
    end
  end

  @spec new(:float, :float, keyword()) :: __MODULE__.t()
  def new(width, height, opts \\ []) do
    struct!(__MODULE__, height: height, width: width)
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

  @impl true
  def to_html(attrs) when is_nil(attrs) do
    []
  end

  def to_html(%__MODULE__{} = attrs) do
    [
      {"height", attrs.height},
      {"width", attrs.width}
    ]
  end

  @spec validate_height(:float) :: true | {false, String.t()}
  defp validate_height(_height) do
    true
  end

  @spec validate_width(:float) :: true | {false, String.t()}
  defp validate_width(_width) do
    true
  end
end
