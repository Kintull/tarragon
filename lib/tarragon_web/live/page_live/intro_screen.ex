defmodule TarragonWeb.PageLive.IntroScreen do
  use TarragonWeb, :live_view

  defmodule CodeForm do
    use Ecto.Schema
    import Ecto.Changeset

    embedded_schema do
      field :code, :integer
    end

    def changeset(attrs \\ %{}) do
      %__MODULE__{}
      |> cast(attrs, [:code])
      |> validate_number(:code, greater_than: 4, less_than: 11)
    end
  end

  def mount(_params, %{}, socket) do
    socket = assign(socket, :form, CodeForm.changeset()|> to_form())
    {:ok, socket, layout: false}
  end

  def handle_event("validate", %{"code_form" => %{"code" => code}}, socket) do
    IO.inspect("Validating code #{code}")
    code_valid = is_binary(code)

    socket = assign(socket, :form, CodeForm.changeset(%{code: code})|> to_form())
    {:noreply, socket}
  end

  def handle_event("save", %{"code_form" => %{"code" => code}}, socket) do
    IO.inspect("Saving code #{code}")
    socket = assign(socket, :form, CodeForm.changeset(%{code: code})|> to_form())
    {:noreply, socket}
  end
end
