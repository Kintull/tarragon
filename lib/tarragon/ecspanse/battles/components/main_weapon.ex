defmodule Tarragon.Ecspanse.Battles.Components.MainWeapon do
  use Ecspanse.Component,
    state: [
      :type,
      :name,
      range: 1,
      projectiles_per_shot: 1,
      damage_per_projectile: 1,
      packed_encumbrance: 0,
      deployed_encumbrance: 0,
      encumbrance: 0,
      packable: false,
      deployed: true
    ],
    tags: [:main_weapon]

  def new(
        name,
        type,
        range,
        projectiles_per_shot,
        damage_per_projectile,
        packable,
        packed_encumbrance,
        encummberance_deployed
      ) do
    {__MODULE__,
     name: name,
     type: type,
     range: range,
     damage_per_projectile: damage_per_projectile,
     projectiles_per_shot: projectiles_per_shot,
     packable: packable,
     encumbrance: packed_encumbrance,
     packed_encumbrance: packed_encumbrance,
     deployed_encumbrance: encummberance_deployed}
  end

  def machine_gun(damage_per_projectile, projectiles_per_shot, range) do
    new("M240", :machine_gun, range, projectiles_per_shot, damage_per_projectile, true, 22, 33)
  end

  def pistol(damage_per_projectile, projectiles_per_shot, range) do
    new("M1911", :pistol, range, projectiles_per_shot, damage_per_projectile, false, 1, 3)
  end

  def sniper_rifle(damage_per_projectile, projectiles_per_shot, range) do
    new("AXSR", :sniper_rifle, range, projectiles_per_shot, damage_per_projectile, true, 16, 24)
  end

  def validate(component) do
    with :ok <- validate_name(component.name),
         :ok <- validate_range(component.range, component.name),
         :ok <- validate_projectiles_per_shot(component.projectiles_per_shot, component.name),
         :ok <- validate_damage_per_projectile(component.damage_per_projectile, component.name),
         :ok <- validate_packed_encumbrance(component.packed_encumbrance, component.name),
         :ok <- validate_deployed_encumbrance(component.deployed_encumbrance, component.name) do
      validate_packed_vs_deployed_encumbrances(
        component.packed_encumbrance,
        component.deployed_encumbrance,
        component.name
      )
    end
  end

  defp validate_packed_vs_deployed_encumbrances(packed, deployed, _name) when packed <= deployed,
    do: :ok

  defp validate_packed_vs_deployed_encumbrances(packed, deployed, name),
    do:
      {:error,
       "encumbrance deployed must greater than or equal to encumbrance packed.  Received deployed #{inspect(deployed)}, packed #{inspect(packed)} for #{name}"}

  defp validate_deployed_encumbrance(val, _name) when is_number(val) and val > 0,
    do: :ok

  defp validate_deployed_encumbrance(val, name),
    do:
      {:error,
       "encumbrance deployed must be a positive number.  Received #{inspect(val)} for #{name}"}

  defp validate_packed_encumbrance(val, _name) when is_number(val) and val > 0,
    do: :ok

  defp validate_packed_encumbrance(val, name),
    do:
      {:error,
       "encumbrance packed must be a positive number.  Received #{inspect(val)} for #{name}"}

  defp validate_damage_per_projectile(val, _name) when is_number(val) and val > 0,
    do: :ok

  defp validate_damage_per_projectile(val, name),
    do:
      {:error,
       "Damaage per Projectile must be a positive number.  Received #{inspect(val)} for #{name}"}

  defp validate_projectiles_per_shot(val, _name) when is_integer(val) and val > 0, do: :ok

  defp validate_projectiles_per_shot(val, name),
    do:
      {:error,
       "Projectiles per Shot must be a positive integer.  Received #{inspect(val)} for #{name}"}

  defp validate_name(nil), do: {:error, "MainWeapons must have a name"}
  defp validate_name(""), do: {:error, "MainWeapons must have a name"}
  defp validate_name(_name), do: :ok

  def validate_range(val, _name) when is_number(val) and val > 0, do: :ok

  def validate_range(val, name),
    do: {:error, "Range must be a positive number.  Received #{inspect(val)} for #{name}"}
end
