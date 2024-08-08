defmodule Tarragon.Ecspanse.GameParameters do
  @moduledoc false
  alias Tarragon.Ecspanse.CombatantParameters
  alias Tarragon.Ecspanse.FragGrenadeParameters
  alias Tarragon.Ecspanse.TeamParameters
  alias Tarragon.Ecspanse.MainWeaponParameters
  alias Tarragon.Ecspanse.MapParameters

  use Ecto.Schema
  import Ecto.Changeset

  schema "game_parameters" do
    field :turns, :integer, default: 30
    embeds_one :blue_team_params, TeamParameters
    embeds_one :red_team_params, TeamParameters
    embeds_one :frag_grenade_params, FragGrenadeParameters
    embeds_one :machine_gunner_params, CombatantParameters
    embeds_one :pistolero_params, CombatantParameters
    embeds_one :sniper_params, CombatantParameters
    embeds_one :map_params, MapParameters

    timestamps()
  end

  @doc false
  def changeset(model, attrs \\ %{}) do
    model
    |> cast(attrs, [:id, :turns])
    |> cast_embed(:blue_team_params, with: &TeamParameters.changeset/2)
    |> cast_embed(:red_team_params, with: &TeamParameters.changeset/2)
    |> cast_embed(:frag_grenade_params, with: &FragGrenadeParameters.changeset/2)
    |> cast_embed(:machine_gunner_params, with: &CombatantParameters.changeset/2)
    |> cast_embed(:pistolero_params, with: &CombatantParameters.changeset/2)
    |> cast_embed(:sniper_params, with: &CombatantParameters.changeset/2)
    |> validate_required([:id, :turns])
    |> validate_number(:turns, greater_than: 0, less_than: 51)
  end

  def new(attrs \\ %{}) do
    struct(
      %__MODULE__{
        turns: 200,
        blue_team_params: %TeamParameters{color: "#0000FF", name: Faker.Team.En.name()},
        red_team_params: %TeamParameters{color: "#FF0000", name: Faker.Team.En.name()},
        frag_grenade_params: %FragGrenadeParameters{},
        machine_gunner_params: %CombatantParameters{
          main_weapon_params: %MainWeaponParameters{
            range: 4,
            projectiles_per_shot: 10,
            damage_per_projectile: 1
          }
        },
        pistolero_params: %CombatantParameters{
          main_weapon_params: %MainWeaponParameters{range: 2, damage_per_projectile: 5}
        },
        sniper_params: %CombatantParameters{
          main_weapon_params: %MainWeaponParameters{range: 7, damage_per_projectile: 10}
        },
        map_params: MapParameters.new()
      },
      attrs
    )
  end
end
