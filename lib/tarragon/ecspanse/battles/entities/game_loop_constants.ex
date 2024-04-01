defmodule Tarragon.Ecspanse.Battles.Entities.GameLoopConstants do
  defmodule MovementDurations do
    defstruct combatants: 1000, grenades: 250, bullets: 100

    @type t :: %__MODULE__{
            combatants: pos_integer(),
            grenades: pos_integer(),
            bullets: pos_integer()
          }
  end

  defmodule StateNames do
    defstruct battle_start: "Battle Start",
              decisions_phase: "Decisions Phase",
              action_phase_start: "Action Phase Start",
              pop_smoke: "Pop Smoke",
              frag_out: "Frag Out",
              dodge: "Dodge",
              deploy_weapons: "Deploy Weapons",
              fire_weapon: "Fire Weapon",
              bullets_impact: "Bullets Impact",
              frag_grenades_detonate: "Frag Grenades Detonate",
              pack_weapons: "Pack Weapons",
              move: "Move",
              action_phase_end: "Action Phase End",
              battle_end: "Battle End"

    @type t :: %__MODULE__{
            battle_start: String.t(),
            decisions_phase: String.t(),
            action_phase_start: String.t(),
            pop_smoke: String.t(),
            frag_out: String.t(),
            dodge: String.t(),
            deploy_weapons: String.t(),
            fire_weapon: String.t(),
            bullets_impact: String.t(),
            frag_grenades_detonate: String.t(),
            pack_weapons: String.t(),
            move: String.t(),
            action_phase_end: String.t(),
            battle_end: String.t()
          }
  end

  defmacro __using__(_) do
    quote do
      @state_names %StateNames{}

      @movement_durations %MovementDurations{}
    end
  end
end
