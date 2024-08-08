defmodule TarragonWeb.PageLive.Ecspanse.Battles.Dump.CombatantComponent do
  alias TarragonWeb.FlexGridLayouts
  alias TarragonWeb.PageLive.Ecspanse.CommonComponents
  use TarragonWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <CommonComponents.properties_card>
        <:header>
          <div class="flex items-start gap-2">
            <h2 class="font-bold text-xl flex-grow">
              <%= @combatant.brand.name %>
            </h2>

            <span class="flex-auto">
              <%= @combatant.brand.icon %>
            </span>
          </div>
        </:header>

        <FlexGridLayouts.auto_grid>
          <CommonComponents.properties_table_from_map
            label="Action Points"
            map={@combatant.action_points}
          /> <CommonComponents.properties_table_from_map label="Entity" map={@combatant.entity} />
          <CommonComponents.properties_table_from_map label="Brand" map={@combatant.brand} />
          <CommonComponents.properties_table_from_map label="Combatant" map={@combatant.combatant} />
          <CommonComponents.properties_table_from_map
            label="Frag Grenades"
            map={@combatant.frag_grenade}
          />
          <CommonComponents.properties_table_from_map label="Health" map={@combatant.health} />
          <CommonComponents.properties_table_from_map
            label="Main Weapon"
            map={@combatant.main_weapon}
          />
          <CommonComponents.properties_table_from_map label="Profession" map={@combatant.profession} />
          <CommonComponents.properties_table_from_map label="Position" map={@combatant.position} />
          <CommonComponents.properties_table_from_map
            label="Smoke Grenades"
            map={@combatant.smoke_grenade}
          />
          <FlexGridLayouts.auto_grid>
            <.live_component
              :for={aa <- @combatant.available_actions}
              module={TarragonWeb.PageLive.Ecspanse.Battles.Dump.AvailableActionComponent}
              id={aa.entity.id}
              action_state={aa}
            />
          </FlexGridLayouts.auto_grid>
        </FlexGridLayouts.auto_grid>
      </CommonComponents.properties_card>
    </div>
    """
  end
end
