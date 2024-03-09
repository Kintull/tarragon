defmodule TarragonWeb.Svg.Attributes.RoundedCornerAttributes do
  @moduledoc """
    Rounded Corner Attributes

    The amount of rounding in x and y directions

    ## Fields
    + **rx** - The amount of rounding in the Horizontal axis
    + **ry** - The amount of rounding in the Vertical axis
  """

  @behaviour TarragonWeb.Svg.Attributes.AttributeBehaviour

  @enforce_keys [:rx, :ry]
  defstruct rx: nil, ry: nil

  @typedoc """
  Rounded Corner Attributes

    + **rx** - The amount of rounding in the Horizontal axis  + **ry** - The amount of rounding in the Vertical axis
  """
  @type t :: %__MODULE__{
          rx: :float,
          ry: :float
        }

  @impl true
  def is_valid?(%__MODULE__{} = attrs) do
    with true <- validate_rx(Map.get(attrs, :rx)),
         true <- validate_ry(Map.get(attrs, :ry)) do
      true
    else
      err -> err
    end
  end

  @spec new(:float, :float, keyword()) :: __MODULE__.t()
  def new(rx, ry, opts \\ []) do
    struct!(__MODULE__, rx: rx, ry: ry)
    |> struct!(opts)
  end

  @spec set_rx(__MODULE__.t(), :float) :: __MODULE__.t()
  def set_rx(attrs, rx) do
    Map.put(attrs, :rx, rx)
  end

  @spec set_ry(__MODULE__.t(), :float) :: __MODULE__.t()
  def set_ry(attrs, ry) do
    Map.put(attrs, :ry, ry)
  end

  @impl true
  def to_html(attrs) when is_nil(attrs) do
    []
  end

  def to_html(%__MODULE__{} = attrs) do
    [
      {"rx", attrs.rx},
      {"ry", attrs.ry}
    ]
  end

  @spec validate_rx(:float) :: true | {false, String.t()}
  defp validate_rx(_rx) do
    true
  end

  @spec validate_ry(:float) :: true | {false, String.t()}
  defp validate_ry(_ry) do
    true
  end
end
