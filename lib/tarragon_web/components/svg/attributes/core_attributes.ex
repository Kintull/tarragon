defmodule TarragonWeb.Svg.Attributes.CoreAttributes do
  @moduledoc """
    Core Attributes

    The core attributes are those attributes that can be specified on any SVG element.

    ## Fields
    + **autofocus** - ask a focusable element to be focused after it's connected to a document.
    + **class** - assigns one or more class names to an element, which can then be used for addressing by the styling language.
    + **id** - Must reflect the element's ID. The ‘id’ attribute must be unique within the node tree, must not be an empty string, and must not contain any whitespace characters.
    + **lang** - specifies the primary language for the element's contents and for any of the element's attributes that contain text. See BCP 47
    + **style** - supply a CSS declaration of an element.
    + **tabindex** - allows authors to control whether an element is focusable, whether it is supposed to be reachable using sequential focus navigation, and what is to be the relative order of the element for the purposes of sequential focus navigation.
  """

  @behaviour TarragonWeb.Svg.Attributes.AttributeBehaviour

  @enforce_keys [:id]
  defstruct autofocus: nil, class: nil, id: nil, lang: nil, style: nil, tabindex: nil

  @typedoc """
  Core Attributes

    + **autofocus** - ask a focusable element to be focused after it's connected to a document.  + **class** - assigns one or more class names to an element, which can then be used for addressing by the styling language.  + **id** - Must reflect the element's ID. The ‘id’ attribute must be unique within the node tree, must not be an empty string, and must not contain any whitespace characters.  + **lang** - specifies the primary language for the element's contents and for any of the element's attributes that contain text. See BCP 47  + **style** - supply a CSS declaration of an element.  + **tabindex** - allows authors to control whether an element is focusable, whether it is supposed to be reachable using sequential focus navigation, and what is to be the relative order of the element for the purposes of sequential focus navigation.
  """
  @type t :: %__MODULE__{
          autofocus: :boolean,
          class: :binary,
          id: :binary,
          lang: :binary,
          style: :binary,
          tabindex: pos_integer()
        }

  @impl true
  def is_valid?(%__MODULE__{} = attrs) do
    with true <- validate_autofocus(Map.get(attrs, :autofocus)),
         true <- validate_class(Map.get(attrs, :class)),
         true <- validate_id(Map.get(attrs, :id)),
         true <- validate_lang(Map.get(attrs, :lang)),
         true <- validate_style(Map.get(attrs, :style)),
         true <- validate_tabindex(Map.get(attrs, :tabindex)) do
      true
    else
      err -> err
    end
  end

  @spec new(:binary, keyword()) :: __MODULE__.t()
  def new(id, opts \\ []) do
    struct!(__MODULE__,
      id: id
    )
    |> struct!(opts)
  end

  @spec set_autofocus(__MODULE__.t(), :boolean) :: __MODULE__.t()
  def set_autofocus(attrs, autofocus) do
    Map.put(attrs, :autofocus, autofocus)
  end

  @spec set_class(__MODULE__.t(), :binary) :: __MODULE__.t()
  def set_class(attrs, class) do
    Map.put(attrs, :class, class)
  end

  @spec set_id(__MODULE__.t(), :binary) :: __MODULE__.t()
  def set_id(attrs, id) do
    Map.put(attrs, :id, id)
  end

  @spec set_lang(__MODULE__.t(), :binary) :: __MODULE__.t()
  def set_lang(attrs, lang) do
    Map.put(attrs, :lang, lang)
  end

  @spec set_style(__MODULE__.t(), :binary) :: __MODULE__.t()
  def set_style(attrs, style) do
    Map.put(attrs, :style, style)
  end

  @spec set_tabindex(__MODULE__.t(), pos_integer()) :: __MODULE__.t()
  def set_tabindex(attrs, tabindex) do
    Map.put(attrs, :tabindex, tabindex)
  end

  @impl true
  def to_html(attrs) when is_nil(attrs) do
    []
  end

  def to_html(%__MODULE__{} = attrs) do
    [
      {"autofocus", attrs.autofocus},
      {"class", attrs.class},
      {"id", attrs.id},
      {"lang", attrs.lang},
      {"style", attrs.style},
      {"tabindex", attrs.tabindex}
    ]
  end

  @spec validate_autofocus(:boolean) :: true | {false, String.t()}
  defp validate_autofocus(_autofocus) do
    true
  end

  @spec validate_class(:binary) :: true | {false, String.t()}
  defp validate_class(_class) do
    true
  end

  @spec validate_id(:binary) :: true | {false, String.t()}
  defp validate_id(_id) do
    true
  end

  @spec validate_lang(:binary) :: true | {false, String.t()}
  defp validate_lang(_lang) do
    true
  end

  @spec validate_style(:binary) :: true | {false, String.t()}
  defp validate_style(_style) do
    true
  end

  @spec validate_tabindex(pos_integer()) :: true | {false, String.t()}
  defp validate_tabindex(_tabindex) do
    true
  end
end
