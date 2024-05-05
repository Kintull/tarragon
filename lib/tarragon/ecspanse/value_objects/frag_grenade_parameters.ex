defmodule Tarragon.Ecspanse.FragGrenadeParameters do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :damage, :integer, default: 5
    field :encumbrance, :integer, default: 2
    field :radius, :integer, default: 2
    field :range, :integer, default: 2
  end

  def changeset(model, attrs \\ %{}) do
    model
    |> cast(attrs, [:damage, :encumbrance, :radius, :range])
    |> validate_required([:damage, :range])
    |> validate_number(:damage, greater_than: 0, less_than: 21)
    |> validate_number(:encumbrance, greater_than: 0, less_than: 21)
    |> validate_number(:radius, greater_than: 0, less_than: 21)
    |> validate_number(:range, greater_than: 0, less_than: 21)
  end
end
