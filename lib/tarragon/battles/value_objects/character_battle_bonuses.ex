defmodule Tarragon.Battles.CharacterBattleBonuses do
  use Ecto.Schema

  alias Tarragon.Repo
  alias Tarragon.Accounts.UserCharacter
  alias Tarragon.Inventory.CharacterItem
  alias Tarragon.Inventory.GameItem

  @type t :: %__MODULE__{}

  embedded_schema do
    field :character_id, :integer, default: 0
    field :nickname, :string, default: ""
    field :player_id, :integer, default: 0
    field :attack_bonus, :integer, default: 0
    field :defence_bonus, :integer, default: 0
    field :health_bonus, :integer, default: 0
    field :max_health, :integer, default: 0
    field :range_bonus, :integer, default: 0
  end

  import Ecto.Query

  def build_character_bonuses(character_id) do
    UserCharacter
    |> where([uc], uc.id == ^character_id)
    |> join(:left, [uc], iw in assoc(uc, :primary_weapon_slot), on: is_nil(iw.id) == false)
    |> join(:left, [uc], ih in assoc(uc, :head_gear_slot), on: is_nil(ih.id) == false)
    |> join(:left, [uc], ic in assoc(uc, :chest_gear_slot), on: is_nil(ic.id) == false)
    |> join(:left, [uc], ik in assoc(uc, :knee_gear_slot), on: is_nil(ik.id) == false)
    |> join(:left, [uc], if in assoc(uc, :foot_gear_slot), on: is_nil(if.id) == false)
    |> join(:left, [uc, iw, ih, ic, ik, if], item in CharacterItem,
      on: item.item_container_id in [iw.id, ih.id, ic.id, ik.id, if.id]
    )
    |> join(:left, [uc, iw, ih, ic, ik, if, item], gi in GameItem, on: gi.id == item.game_item_id)
    |> group_by([uc], uc.id)
    |> select([uc, iw, ih, ic, ik, if, items, gi], %__MODULE__{
      character_id: uc.id,
      nickname: uc.nickname,
      attack_bonus: sum(gi.base_damage_bonus),
      defence_bonus: sum(gi.base_defence_bonus),
      health_bonus: sum(gi.base_health_bonus),
      max_health: uc.max_health + sum(gi.base_health_bonus),
      range_bonus: sum(gi.base_range_bonus)
    })
    |> Repo.one()
  end
end
