defmodule Tarragon.Ecspanse.Battles.Systems.Synchronous.BattleSpawner do
  @moduledoc """
  Spawns Battles
  """
  alias Tarragon.Ecspanse.Withables
  alias Tarragon.Ecspanse.Battles.Events
  alias Tarragon.Ecspanse.Battles.Entities

  use Ecspanse.System,
    event_subscriptions: [Events.SpawnBattleRequest]

  def run(%Events.SpawnBattleRequest{}, _frame) do
    red_team_name = Faker.Team.En.name()
    blue_team_name = Faker.Team.En.name()

    battle_entity =
      Ecspanse.Command.spawn_entity!(
        Entities.Battle.blueprint("#{red_team_name} vs. #{blue_team_name}")
      )

    IO.puts(EcspanseStateMachine.as_mermaid_diagram(battle_entity.id) |> Withables.val_or_nil())

    [red_team, blue_team] =
      Ecspanse.Command.spawn_entities!([
        Entities.Team.blueprint(1, red_team_name, "#F00", "🚩", battle_entity),
        Entities.Team.blueprint(-1, blue_team_name, "#00F", "🏴", battle_entity)
      ])

    Ecspanse.Command.spawn_entities!([
      Entities.Combatant.pistolero_blueprint(Faker.Person.first_name(), 0, red_team),
      Entities.Combatant.gunner_blueprint(Faker.Person.first_name(), 0, red_team),
      Entities.Combatant.sniper_blueprint(Faker.Person.first_name(), 0, red_team),
      Entities.Combatant.pistolero_blueprint(Faker.Person.first_name(), 17, blue_team),
      Entities.Combatant.gunner_blueprint(Faker.Person.first_name(), 17, blue_team),
      Entities.Combatant.sniper_blueprint(Faker.Person.first_name(), 17, blue_team)
    ])
  end
end
