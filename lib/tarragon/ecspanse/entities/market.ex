defmodule Tarragon.Ecspanse.Entities.Market do
  @moduledoc """
  Markets have a MarketComponent and a MarketRestockTimer
  """
  alias Tarragon.Ecspanse.Components

  @spec new() :: Ecspanse.Entity.entity_spec()
  @doc """
  The new/0 function does not have any effect.
  It just prepares the entity spec (of type Ecspanse.Entity.entity_spec/0) to be spawned.
  """
  def new do
    {Ecspanse.Entity,
     components: [
       Components.Market,
       Components.MarketRestockTimer
     ]}
  end
end
