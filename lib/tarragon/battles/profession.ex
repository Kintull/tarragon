defmodule Tarragon.Battles.Profession do
  use Ecto.Schema
  import Ecto.Changeset

  schema "professions" do
    field :name, :string
    field :description, :string
    field :speed, :integer
    field :health_points, :integer

    timestamps()
  end

  @doc false
  def changeset(profession, attrs) do
    profession
    |> cast(attrs, [:name, :description, :health_points, :speed])
    |> validate_required([:name, :description, :health_points, :speed])
  end

  def all do
    [
      %__MODULE__{
        name: "Pistolero",
        description: "A short range fighter",
        health_points: 20,
        speed: 1
      },
      %__MODULE__{
        name: "Machinegunner",
        description: "A medium range fighter with burst fire weapons",
        health_points: 20,
        speed: 1
      },
      %__MODULE__{
        name: "Machinegunner",
        description: "A medium range fighter with burst fire weapons",
        health_points: 20,
        speed: 1
      }
    ]
  end
end
