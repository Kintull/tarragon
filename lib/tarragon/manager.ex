defmodule Tarragon.Manager do
  @moduledoc """
  ECSx manager.
  """
  use ECSx.Manager

  def setup do
    # Seed persistent components only for the first server start
    # (This will not be run on subsequent app restarts)

    :ok
  end

  def startup do
    # Load ephemeral components during first server start and again
    # on every subsequent app restart

    :ok
  end

  # Declare all valid Component types
  def components do
    [
      Tarragon.Components.HealthIncrementTarget,
      Tarragon.Components.DamageOverTimeName,
      Tarragon.Components.DamageOverTimeTarget,
      Tarragon.Components.DamageOverTimeOccurrencesRemaining,
      Tarragon.Components.DamageOverTimeRateInMs,
      Tarragon.Components.DamageOverTimeScheduledPointLoss,
      Tarragon.Components.OneShotDamageTarget,
      Tarragon.Components.OneShotDamagePoints,
      Tarragon.Components.DisplayName,
      Tarragon.Components.HealthIncrementPoints,
      Tarragon.Components.HealthMaxPoints,
      Tarragon.Components.HealthPoints,
      Tarragon.Components.HealthRegenerationRateInMs,
      Tarragon.Components.HealthRegenerationScheduledRecovery,
      Tarragon.Components.HealthRegenerationStatus
    ]
  end

  # Declare all Systems to run
  def systems do
    [
      Tarragon.Systems.DamageOverTimePointLossExecutor,
      Tarragon.Systems.DamageOverTimeScheduler,
      Tarragon.Systems.OneShotDamageExecutor,
      Tarragon.Systems.ClientEventHandler,
      Tarragon.Systems.HealthPointIncrementor,
      Tarragon.Systems.HealthRegenerationScheduler,
      Tarragon.Systems.HealthRegenerationStatusUpdater,
      Tarragon.Systems.HealthRegenerationRecoveryExecutor
    ]
  end
end
