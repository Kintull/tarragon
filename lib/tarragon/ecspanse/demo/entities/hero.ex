defmodule Tarragon.Ecspanse.Demo.Entities.Hero do
  @moduledoc """
  This is a hero entity.  A hero has
  * Name
  * Health
  * Energy
  * Position
  """
  alias Tarragon.Ecspanse.Demo.Components.Currencies
  alias Tarragon.Ecspanse.Demo.Components

  @spec new() :: Ecspanse.Entity.entity_spec()
  @doc """
  The new/0 function does not have any effect.
  It just prepares the entity spec (of type Ecspanse.Entity.entity_spec/0) to be spawned.
  """
  def new do
    {Ecspanse.Entity,
     components: [
       Components.Hero,
       Components.Energy,
       Components.EnergyRegenTimer,
       Components.Health,
       Components.HealthRegenTimer,
       Components.Position,
       {Currencies.Gems, [], [:available]},
       {Currencies.Gold, [], [:available]}
     ]}
  end
end
