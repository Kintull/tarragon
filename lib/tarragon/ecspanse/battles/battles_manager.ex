defmodule Tarragon.Ecspanse.Battles.BattlesManager do
  @moduledoc """
  Adds the demo systems to the expanse manager.  That is, if you want the demo system to be active,
  call setup from the ecspanse manager.
  """

  alias Tarragon.Ecspanse.Battles.Systems

  def setup(data) do
    data
    |> EcspanseStateMachine.setup()
    #
    # system startup
    #
    # |> Ecspanse.add_startup_system(Systems.Startup.SpawnABattle)
    #
    # frame start
    #
    |> Ecspanse.add_frame_start_system(Systems.Synchronous.BattleSpawnerV2)
    |> Ecspanse.add_frame_start_system(Systems.Synchronous.NewBattleMonitor)
    |> Ecspanse.add_frame_start_system(Systems.Synchronous.OnScheduleAvailableAction)
    |> Ecspanse.add_frame_start_system(Systems.Synchronous.OnSelectMoveTile)
    |> Ecspanse.add_frame_start_system(Systems.Synchronous.OnSelectAttackTarget)
    |> Ecspanse.add_frame_start_system(Systems.Synchronous.OnCancelScheduledAction)
    |> Ecspanse.add_frame_start_system(Systems.Synchronous.OnLockIntentions)
    |> Ecspanse.add_frame_start_system(Systems.Synchronous.MovingAnimator)
    |> Ecspanse.add_frame_start_system(Systems.Synchronous.MovingAnimatorStep)
    # state machine
    # |> Ecspanse.add_frame_start_system(Systems.GameLoop.StateChangeInspector)
    |> Ecspanse.add_frame_start_system(Systems.GameLoop.OnEnterActionPhaseEnd)
    |> Ecspanse.add_frame_start_system(Systems.GameLoop.OnEnterActionPhaseStart)
    |> Ecspanse.add_frame_start_system(Systems.GameLoop.OnEnterBattleEnd)
    |> Ecspanse.add_frame_start_system(Systems.GameLoop.OnEnterBattleStart)
    |> Ecspanse.add_frame_start_system(Systems.GameLoop.OnEnterBulletsImpact)
    |> Ecspanse.add_frame_start_system(Systems.GameLoop.OnEnterDecisionsPhase)
    |> Ecspanse.add_frame_start_system(Systems.GameLoop.OnStateChange)
    |> Ecspanse.add_frame_start_system(Systems.GameLoop.OnEnterDeployWeapons)
    |> Ecspanse.add_frame_start_system(Systems.GameLoop.OnEnterDodge)
    |> Ecspanse.add_frame_start_system(Systems.GameLoop.OnEnterFragOut)
    |> Ecspanse.add_frame_start_system(Systems.GameLoop.OnEnterFragGrenadesDetonate)
    |> Ecspanse.add_frame_start_system(Systems.GameLoop.OnEnterFireWeapon)
    |> Ecspanse.add_frame_start_system(Systems.GameLoop.OnEnterMove)
    |> Ecspanse.add_frame_start_system(Systems.GameLoop.OnEnterPackWeapons)
    |> Ecspanse.add_frame_start_system(Systems.GameLoop.OnEnterPopSmoke)
    |> Ecspanse.add_frame_start_system(Systems.GameLoop.OnExitDecisionsPhase)

    # `
    # every frame`
    # `

    #
    # frame end
    #
  end
end
