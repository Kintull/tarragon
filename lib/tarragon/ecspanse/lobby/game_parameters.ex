defmodule Tarragon.Ecspanse.Lobby.FragGrenadeParameters do
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

defmodule Tarragon.Ecspanse.Lobby.MainWeaponParameters do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :damage_per_projectile, :integer, default: 5
    field :projectiles_per_shot, :integer, default: 1
    field :range, :integer, default: 3
  end

  def changeset(model, attrs \\ %{}) do
    model
    |> cast(attrs, [:damage_per_projectile, :projectiles_per_shot, :range])
    |> validate_required([:damage_per_projectile, :projectiles_per_shot, :range])
    |> validate_number(:damage_per_projectile, greater_than: 0, less_than: 21)
    |> validate_number(:projectiles_per_shot, greater_than: 0, less_than: 11)
    |> validate_number(:range, greater_than: 0, less_than: 11)
  end
end

defmodule Tarragon.Ecspanse.Lobby.TeamParameters do
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

defmodule Tarragon.Ecspanse.Lobby.CombatantParameters do
  @moduledoc false
  alias Tarragon.Ecspanse.Lobby.MainWeaponParameters
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

defmodule Tarragon.Ecspanse.Lobby.GameParameters do
  @moduledoc false
  alias Tarragon.Ecspanse.Lobby.CombatantParameters
  alias Tarragon.Ecspanse.Lobby.FragGrenadeParameters
  alias Tarragon.Ecspanse.Lobby.TeamParameters
  alias Tarragon.Ecspanse.Lobby.MainWeaponParameters
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
        turns: 30,
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
        }
      },
      attrs
    )
  end
end
