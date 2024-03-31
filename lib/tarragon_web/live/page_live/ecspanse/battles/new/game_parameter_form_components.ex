defmodule TarragonWeb.PageLive.Ecspanse.Battles.New.GameParameterFormComponents do
  use TarragonWeb, :html

  attr :title, :string, default: "Frag Grenades"
  attr :frag_grenade_params_form_field, Phoenix.HTML.FormField

  def frag_grenade_params(assigns) do
    ~H"""
    <div>
      <div class="font-bold"><%= @title %></div>
      <div class="grid grid-cols-3 gap-2">
        <.inputs_for :let={frag_grenade_params} field={@frag_grenade_params_form_field}>
          <.input field={frag_grenade_params[:range]} label="Range" type="number" />
          <.input field={frag_grenade_params[:damage]} label="Damage" type="number" />
        </.inputs_for>
      </div>
    </div>
    """
  end

  attr :title, :string
  attr :main_weapon_params_form_field, Phoenix.HTML.FormField

  def main_weapon_params(assigns) do
    ~H"""
    <div>
      <div class="font-bold"><%= @title %></div>
      <div class="grid grid-cols-3 gap-2">
        <.inputs_for :let={main_weapon_params} field={@main_weapon_params_form_field}>
          <.input field={main_weapon_params[:range]} label="Range" type="number" />
          <.input
            field={main_weapon_params[:projectiles_per_shot]}
            label="Projectiles Per Shot"
            type="number"
          />
          <.input
            field={main_weapon_params[:damage_per_projectile]}
            label="Damage per Projectile"
            type="number"
          />
        </.inputs_for>
      </div>
    </div>
    """
  end

  attr :title, :string
  attr :team_params_form_field, Phoenix.HTML.FormField

  def team_params(assigns) do
    ~H"""
    <div>
      <div class="font-bold"><%= @title %></div>
      <div class="grid grid-cols-1 gap-2">
        <.inputs_for :let={team_params} field={@team_params_form_field}>
          <.input field={team_params[:name]} label="Name" />
        </.inputs_for>
      </div>
    </div>
    """
  end

  attr :title, :string
  attr :combatant_params_form_field, Phoenix.HTML.FormField

  def combatant_params(assigns) do
    ~H"""
    <div>
      <div class="font-bold"><%= @title %></div>
      <div class="grid grid-cols-1 gap-2">
        <.inputs_for :let={combatant_params} field={@combatant_params_form_field}>
          <.input field={combatant_params[:max_health]} type="number" label="Max Health" />
          <.main_weapon_params
            main_weapon_params_form_field={combatant_params[:main_weapon_params]}
            title="Main Weapon"
          />
        </.inputs_for>
      </div>
    </div>
    """
  end
end
