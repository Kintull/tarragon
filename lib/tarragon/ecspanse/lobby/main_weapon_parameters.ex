defmodule Tarragon.Ecspanse.MainWeaponParameters do
  use Ecto.Schema
  import Ecto.Changeset

  schema "main_weapon_parameters" do
    field :range, :integer, default: 2
    field :projectiles_per_shot, :integer, default: 1
    field :damage_per_projectile, :integer, default: 5

    timestamps()
  end

  @doc false
  def changeset(model, attrs) do
    model
    |> cast(attrs, [:range, :projectiles_per_shot, :damage_per_projectile])
    |> validate_required([:range, :projectiles_per_shot, :damage_per_projectile])
    |> validate_number(:range, greater_than: 0, less_than: 11)
    |> validate_number(:projectiles_per_shot, greater_than: 0, less_than: 11)
    |> validate_number(:damage_per_projectile, greater_than: 0, less_than: 21)
  end
end
