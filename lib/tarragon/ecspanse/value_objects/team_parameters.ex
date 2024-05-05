defmodule Tarragon.Ecspanse.TeamParameters do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name, :string
    field :color, :string, default: "#000000"
  end

  def changeset(model, attrs \\ %{}) do
    model
    |> cast(attrs, [:name, :color])
    |> validate_required([:name, :color])
    |> validate_length(:name, greater_than: 0, less_than: 21)
    |> validate_length(:color, greater_than: 7, less_than: 7)
  end
end
