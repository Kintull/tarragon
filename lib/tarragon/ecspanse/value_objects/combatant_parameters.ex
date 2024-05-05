defmodule Tarragon.Ecspanse.CombatantParameters do
  @moduledoc false
  alias Tarragon.Ecspanse.MainWeaponParameters
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :max_health, :integer, default: 20
    embeds_one :main_weapon_params, MainWeaponParameters
  end

  @spec changeset(
          {map(), map()}
          | %{
              :__struct__ => atom() | %{:__changeset__ => map(), optional(any()) => any()},
              optional(atom()) => any()
            }
        ) :: map()
  def changeset(model, attrs \\ %{}) do
    model
    |> cast(attrs, [:max_health])
    |> validate_required([:max_health])
    |> validate_number(:max_health, greater_than: 0, less_than: 21)
    |> cast_embed(:main_weapon_params, with: &MainWeaponParameters.changeset/2)
  end
end
