defmodule TarragonWeb.PageLive.BattleScreenV3 do
  use TarragonWeb, :live_view

  alias Tarragon.Battles
  alias Tarragon.Ecspanse.Battles.Lookup
  alias Tarragon.Ecspanse.Battles.Projections
  alias Tarragon.Ecspanse.Battles.Components

  @impl true
  def mount(_params, session, socket) do
    session_char_int = Map.get(session, "user_id")
    IO.inspect(session_char_int, label: "character from session")

    character = if session_char_int do
      get_player_character(session_char_int)
      else
      get_player_character()
    end
    character.id |> IO.inspect(label: "player_character_id")
    room = Battles.impl().get_character_active_room(character.id)
    {ally_team, enemy_team} = split_ally_enemy_teams(character.id, room.participants)

    selected_enemy = hd(enemy_team)

    seconds_left = 20

    {:ok, combatant_projection} = Tarragon.Ecspanse.Battles.Api.find_combatant_by_user_character_id(character.id)
    %{current: current_energy, max: max_energy} = combatant_projection.action_points
    energy_regen = combatant_projection.combatant.action_points_per_turn

    avatars_by_ids =
      Enum.into(room.participants, %{}, fn participant ->
        {participant.user_character_id, participant.user_character.avatar_url}
      end)

    max_health_points_by_ids =
      Enum.into(room.participants, %{}, fn participant ->
        {:ok, combatant_projection} = Tarragon.Ecspanse.Battles.Api.find_combatant_by_user_character_id(participant.user_character_id)
        IO.inspect("#{participant.user_character_id} - #{combatant_projection.entity.id}")
        {participant.user_character_id,
          combatant_projection.health.max}
      end)

    current_health_points_by_ids = max_health_points_by_ids

    character_ids_by_locations =
      (ally_team ++ enemy_team)
      |> Enum.into(%{}, fn character ->
        {:ok, combatant_projection} = Tarragon.Ecspanse.Battles.Api.find_combatant_by_user_character_id(character.id)
        {combatant_projection.position, character.id}
      end)

    #    {:ok, ecs_battle_entity} = Tarragon.Ecspanse.Battles.Api.find_battle_by_game(room.id)
    #    {:ok, ecs_combatant_entity} = Tarragon.Ecspanse.Battles.Api.find_combatant_by_user_character_id(character.id)

    # option 1 - extend grid where every cell is a container, and it has properties like highlighted, selected, etc.
    # option 2 - store options for cells in an action state, and render them based on that state

    {:ok, battle_projection} = Tarragon.Ecspanse.Battles.Api.find_battle_by_game(room.id)
    turn = battle_projection.battle.turn
    is_decision_phase = battle_projection.state_machine.current_state == "Decision Phase"

    if connected?(socket) do
      Projections.Battle.start!(%{entity_id: battle_projection.entity.id, client_pid: self()})
    end

    Enum.each(
      (ally_team ++ enemy_team),
      fn character ->
        {:ok, combatant_entity} = Tarragon.Ecspanse.Battles.Api.find_combatant_entity_by_user_character_id(character.id)
        Projections.Combatant.start!(%{entity_id: combatant_entity.id, client_pid: self()})
      end
    )

    {:ok, ecs_combatant_projection} = Tarragon.Ecspanse.Battles.Api.find_combatant_by_user_character_id(character.id)

    move_action =
      ecs_combatant_projection.available_actions
      |> Enum.find(& &1.action.action_group == :movement)

    attack_action =
      ecs_combatant_projection.available_actions
      |> Enum.find(& &1.action.action_group == :attack)

    defence_action =
      ecs_combatant_projection.available_actions
      |> Enum.find(& &1.action.action_group == :defense)

    weapon_range = ecs_combatant_projection.main_weapon.range

    ecs_combatant_projection.combatant.user_id |> IO.inspect(label: "mount user_id")
    attack_target_options = ecs_combatant_projection.attack_target_options |> IO.inspect(label: "mount atk options")

    step_action_state = init_step_action_state(attack_action.action.action_point_cost, move_action.action_state.is_available)
    attack_action_state = init_attack_action_state(attack_action.action.action_point_cost, attack_action.action_state.is_available, weapon_range, attack_target_options)
    dodge_action_state = init_dodge_action_state(defence_action.action.action_point_cost, defence_action.action_state.is_available)
    grid_state = init_grid_state(character_ids_by_locations, battle_projection.grid)

    socket =
      socket
      |> assign(is_decision_phase: is_decision_phase)
      |> assign(combatant_projections: %{character.id => ecs_combatant_projection})
      |> assign(turn: turn)
      |> assign(ally_score: 0)
      |> assign(enemy_score: 0)
      |> assign(player_location: 0)
      |> assign(enemy_location: 0)
      |> assign(seconds_left: seconds_left)
      |> assign(player_character_id: character.id)
      |> assign(target_character_id: selected_enemy.id)
      |> assign(all_character_ids: (ally_team ++ enemy_team) |> Enum.map(& &1.id))
      |> assign(ally_character_ids: ally_team |> Enum.map(& &1.id))
      |> assign(enemy_character_ids: enemy_team |> Enum.map(& &1.id))
      |> assign(avatars_by_ids: avatars_by_ids)
      |> assign(current_health_points_by_ids: current_health_points_by_ids)
      |> assign(max_health_points_by_ids: max_health_points_by_ids)
      |> assign(
        action_related_keys: [
          :action_to_state_name,
          :attack_action_state,
          :dodge_action_state,
          :step_action_state,
          :energy_state,
          :grid_state,
          :player_character_id,
          :enemy_character_ids
        ]
      )
      |> assign(
        action_to_state_name: %{
          "attack" => :attack_action_state,
          "dodge" => :dodge_action_state,
          "step" => :step_action_state,
          "step_move_select" => :step_action_state
        }
      )
      |> assign(attack_action_state: attack_action_state)
      |> assign(dodge_action_state: dodge_action_state)
      |> assign(step_action_state: step_action_state)
      |> assign(energy_state: init_energy_state(max_energy: max_energy, current_energy: current_energy, energy_regen: energy_regen))
      |> assign(grid_state: grid_state)
      |> assign(bg_tile_size: 200)
      |> assign(room_id: room.id)

    {:ok, socket, layout: false}
  end

  def init_grid_state(character_ids_by_locations, grid) do
    # hexagonal grid coordinates include x, y, z, where x + y + z = 0
    # creating a hexagonal grid with 7 hexagons
    # outer_r = 20
    # inner_r = round(outer_r * 0.86602540378)
    # generate_grid_circle_flat
    #    grid = generate_grid_rectangle_flat(9, 5, cell_width)
    #    grid = generate_grid_rectangle_pointy(9, 5, cell_width)
    #    grid = generate_grid_circle_pointy(3, cell_width)

    %{
      name: :grid_state,
      move_options: [],
      selected_move: nil,
      attack_range_highlights: [],
      attack_target_options: [],
      selected_attack_target: nil,
      selected_attack_location: nil,
      character_ids_by_locations: character_ids_by_locations,
      grid: grid
    }
  end

  @impl true
  def handle_info({:projection_updated, %{result: projection = %Projections.Battle{}}}, socket) do
    time = projection.state_machine.time

    is_decision_phase = projection.state_machine.current_state == "Decisions Phase"

    socket =
      socket
      |> assign(seconds_left: round(time/1000))
      |> assign(is_decision_phase: is_decision_phase)

    {:noreply, socket}
  end

  def handle_info({:projection_updated, %{result: combatant_projection = %Projections.Combatant{}}}, socket) do
#    IO.inspect("projection_updated Projections.Combatant")
#    if socket.assigns.player_character_id == combatant_projection.combatant.user_id do
#      Map.keys(combatant_projection)
#        |> Enum.each(fn key ->
#        diff = MapDiff.diff(Map.get(socket.assigns.combatant_projections[socket.assigns.player_character_id], key), Map.get(combatant_projection, key))
#        if diff.changed != :equal do
#          IO.inspect(Map.drop(diff, [:changed, :value]), label: key)
#        end
#      end)
#    end
    old_character_ids_by_locations = socket.assigns.grid_state.character_ids_by_locations

    current_health_points_by_ids = socket.assigns.current_health_points_by_ids
    character_id = combatant_projection.combatant.user_id
    current_health = combatant_projection.health.current
    new_current_health_points_by_ids = Map.put(current_health_points_by_ids, character_id, current_health)

    new_character_ids_by_locations =
      Enum.into(old_character_ids_by_locations, %{}, fn {location, character_id} ->
        new_location =
          if character_id == combatant_projection.combatant.user_id do
            combatant_projection.position
          else
            location
          end
        {new_location, character_id}
      end)

    new_grid_state = %{ socket.assigns.grid_state |  character_ids_by_locations: new_character_ids_by_locations}

    new_energy_state =
      if combatant_projection.combatant.user_id == socket.assigns.player_character_id do
        %{current: current_energy, max: max_energy} = combatant_projection.action_points
        energy_regen = combatant_projection.combatant.action_points_per_turn
        init_energy_state(max_energy: max_energy, current_energy: current_energy, energy_regen: energy_regen)
      else
        socket.assigns.energy_state
      end

    old_dodge_action_state = socket.assigns.dodge_action_state
    old_step_action_state = socket.assigns.step_action_state
    old_attack_action_state = socket.assigns.attack_action_state


    new_dodge_action_state =
      if combatant_projection.combatant.user_id == socket.assigns.player_character_id do
        dodge_action =
          combatant_projection.available_actions
          |> Enum.find(& &1.action.action_group == :defense)

        case dodge_action do
          %{action_state: %{is_scheduled: false}} ->
            init_dodge_action_state(dodge_action.action.action_point_cost, dodge_action.action_state.is_available)
          _ ->
            old_dodge_action_state
        end
      else
        old_dodge_action_state
      end

    {new_step_action_state, new_grid_state} =
      if combatant_projection.combatant.user_id == socket.assigns.player_character_id do
        movement_action =
          combatant_projection.available_actions
          |> Enum.find(& &1.action.action_group == :movement)

        case movement_action do
          %{action_state: %{is_scheduled: false}} ->
            {
              init_step_action_state(movement_action.action.action_point_cost, movement_action.action_state.is_available),
              %{new_grid_state | move_options: [], selected_move: nil}
            }

          _ ->
            {old_step_action_state, new_grid_state}
        end
      else
        {old_step_action_state, new_grid_state}
      end

    {new_attack_action_state, new_grid_state} =
      if combatant_projection.combatant.user_id == socket.assigns.player_character_id do
        attack_action =
          combatant_projection.available_actions
          |> Enum.find(& &1.action.action_group == :attack)

        weapon_range = combatant_projection.main_weapon.range
        attack_target_options = combatant_projection.attack_target_options

        case attack_action do
          %{action_state: %{is_scheduled: false}} ->
            {
              init_attack_action_state(attack_action.action.action_point_cost, attack_action.action_state.is_available, weapon_range, attack_target_options),
              %{new_grid_state | attack_range_highlights: [], selected_attack_target: nil, selected_attack_location: nil}
            }

          _ ->
            {old_attack_action_state, new_grid_state}
        end
      else
        {old_attack_action_state, new_grid_state}
      end

    user_id = combatant_projection.combatant.user_id

    socket =
      socket
      |> assign(grid_state: new_grid_state)
      |> assign(energy_state: new_energy_state)
      |> assign(step_action_state: new_step_action_state)
      |> assign(attack_action_state: new_attack_action_state)
      |> assign(dodge_action_state: new_dodge_action_state)
      |> assign(current_health_points_by_ids: new_current_health_points_by_ids)
      |> assign(combatant_projections: Map.put(socket.assigns.combatant_projections, user_id, combatant_projection))

    {:noreply, socket}
  end

  @impl true
  def handle_event("resized", _params, socket) do
    IO.inspect("handle_event(resized/battle_screen_v3)")

    {:noreply, socket}
  end

  def handle_event("character-clicked", %{"character_id" => id}, socket) do
    IO.inspect("handle_event(character-clicked/battle_screen_v3) #{id}")
    id = String.to_integer(id)

    selected_enemy_id =
      if id in socket.assigns.enemy_character_ids,
        do: id,
        else: socket.assigns.target_character_id

    socket = assign(socket, target_character_id: selected_enemy_id)
    {:noreply, socket}
  end

  def handle_event("tile_click", %{"coords" => coords_raw}, socket) do
    IO.inspect("tile_click")
    [x,y,z] = String.split(coords_raw) |> Enum.map(&String.to_integer/1)
    coords = %{x: x, y: y, z: z}

    updated_states =
      cond do
        socket.assigns.step_action_state.state == :active ->
          process_action_event(
            "tile_click",
            :step_action_state,
            Map.take(socket.assigns, socket.assigns.action_related_keys),
            %{coords: coords}
          )
        true ->
          []
      end

    socket = Enum.reduce(updated_states, socket, fn {k, v}, acc -> assign(acc, k, v) end)

    {:noreply, socket}
  end


  def handle_event("character_click", %{"character_id" => character_id_raw}, socket) do
    IO.inspect("character_click id: #{character_id_raw}")
    character_id = String.to_integer(character_id_raw)

    updated_states =
      cond do
        socket.assigns.attack_action_state.state == :active ->
          process_action_event(
            "character_click",
            :attack_action_state,
            Map.take(socket.assigns, socket.assigns.action_related_keys),
            %{character_id: character_id}
          )
        true ->
          []
      end

    socket = Enum.reduce(updated_states, socket, fn {k, v}, acc -> assign(acc, k, v) end)

    {:noreply, socket}
  end

  def handle_event("action_click" = event, %{"action" => action}, socket) do
    if action not in Map.keys(socket.assigns.action_to_state_name), do: raise("Unknown action")

    state_name = socket.assigns.action_to_state_name[action]

    updated_states =
      process_action_event(
        event,
        state_name,
        Map.take(socket.assigns, socket.assigns.action_related_keys)
      )

    socket = Enum.reduce(updated_states, socket, fn {k, v}, acc -> assign(acc, k, v) end)
    {:noreply, socket}
  end

  def handle_event("cancel_action" = event, %{"action" => action}, socket) do
    if action not in Map.keys(socket.assigns.action_to_state_name), do: raise("Unknown action")

    state_name = socket.assigns.action_to_state_name[action]

    updated_states =
      process_action_event(
        event,
        state_name,
        Map.take(socket.assigns, socket.assigns.action_related_keys)
      )

    socket = Enum.reduce(updated_states, socket, fn {k, v}, acc -> assign(acc, k, v) end)
    {:noreply, socket}
  end

  def process_action_event(event, state_name, assigns, params \\ %{}) do
    case state_name do
      :attack_action_state -> process_attack_action_event(event, state_name, assigns, params)
      :dodge_action_state -> process_dodge_action_event(event, state_name, assigns)
      :step_action_state -> process_step_action_event(event, state_name, assigns, params)
    end

    # UPDATE: for now update avilability by receiving async events
    # based on new energy state, update action states, enable/disable actions
#    new_energy_state = new_states.energy_state
#    all_action_state_keys = Map.values(assigns.action_to_state_name)
#
#    Enum.into(
#      all_action_state_keys,
#      new_states,
#      fn action_name ->
#        {action_name, maybe_make_action_unavailable(new_states[action_name], new_energy_state)}
#      end
#    )
  end

  def process_step_action_event(event, state_name, assigns, params \\ %{}) do
    energy_state = assigns.energy_state
    grid_state = assigns.grid_state
    old_state = assigns[state_name]
    selected_coords = params[:coords]

    new_state =
      cond do
        event == "tile_click" and old_state.state == :active and (selected_coords in grid_state.move_options) ->
          %{old_state | state: :active_completed}

        event == "action_click" and old_state.state == :idle ->
          %{old_state | state: :active}

        event == "cancel_action" and old_state.state in [:active, :active_completed] ->
          %{old_state | state: :idle}

        true ->
          old_state
      end

    new_energy_state =
      case {old_state.state, new_state.state} do
        {:idle, :active} ->
          %{
            energy_state
          | current_energy: energy_state.current_energy - assigns[state_name].energy_cost
          }

        {_any, :idle} ->
          %{
            energy_state
          | current_energy: energy_state.current_energy + assigns[state_name].energy_cost
          }

        _ ->
          energy_state
      end

    new_grid_state =
      case {old_state.state, new_state.state} do
        {:idle, :active} ->
          player_character_id = assigns.player_character_id
          {character_location, _id} = Enum.find(grid_state.character_ids_by_locations, fn {_, id} -> id == player_character_id end)
          highlighted_cells = Tarragon.Ecspanse.MapParameters.neighbours(character_location, 1)

          %{
            grid_state
          | move_options: highlighted_cells
          }

        {_any, :idle} ->
          %{
            grid_state
          | move_options: [], selected_move: nil
          }

        {:active, :active_completed} ->
          %{
            grid_state
          | move_options: [], selected_move: selected_coords
          }

        _ ->
          grid_state
      end

    # state machine side effects:
    # submit or remove the action in ECS system so it can get processed
    case {old_state.state, new_state.state} do
      {:active, :active_completed} ->
        player_character_id = assigns.player_character_id
        {:ok, ecs_combatant_entity} = Tarragon.Ecspanse.Battles.Api.find_combatant_entity_by_user_character_id(player_character_id)

        [action] =
          Lookup.list_descendants(ecs_combatant_entity, Components.ActionState)
          |> Enum.filter(
               &match?({:ok, _}, Ecspanse.Query.fetch_tagged_component(&1, [:action, :movement]))
             )

      %{x: x, y: y, z: z} = selected_coords
      Tarragon.Ecspanse.Battles.Api.schedule_available_action(action.id)
      Tarragon.Ecspanse.Battles.Api.update_move_direction(ecs_combatant_entity.id, x, y ,z)

      {:active_completed, :idle} ->
        player_character_id = assigns.player_character_id
        {:ok, ecs_combatant_entity} = Tarragon.Ecspanse.Battles.Api.find_combatant_entity_by_user_character_id(player_character_id)

        [action_entity] = Lookup.list_descendants(ecs_combatant_entity, Components.ActionState)
                 |> Enum.filter(
                      &match?({:ok, _}, Ecspanse.Query.fetch_tagged_component(&1, [:action, :movement]))
                    )

        Tarragon.Ecspanse.Battles.Api.cancel_scheduled_action(action_entity.id)

      _ ->
        :ok
    end


    Map.merge(assigns, %{state_name => new_state, energy_state: new_energy_state, grid_state: new_grid_state})
  end


  def process_dodge_action_event(event, state_name, assigns) do
    energy_state = assigns.energy_state
    old_state = assigns[state_name]

    new_state =
      cond do
        event == "action_click" and old_state.state == :idle ->
          %{old_state | state: :active}

        event == "cancel_action" and old_state.state == :active ->
          %{old_state | state: :idle}

        true ->
          old_state
      end

    new_energy_state =
      case {old_state.state, new_state.state} do
        {:idle, :active} ->
          %{
            energy_state
          | current_energy: energy_state.current_energy - assigns[state_name].energy_cost
          }

        {_any, :idle} ->
          %{
            energy_state
          | current_energy: energy_state.current_energy + assigns[state_name].energy_cost
          }

        _ ->
          energy_state
      end

    case {old_state.state, new_state.state} do
      {:active, :active_completed} ->
        player_character_id = assigns.player_character_id
        {:ok, player_combatant_entity} = Tarragon.Ecspanse.Battles.Api.find_combatant_entity_by_user_character_id(player_character_id)

        [action] =
          Lookup.list_descendants(player_combatant_entity, Components.ActionState)
          |> Enum.filter(
               &match?({:ok, _}, Ecspanse.Query.fetch_tagged_component(&1, [:action, :dodge]))
             )

        Tarragon.Ecspanse.Battles.Api.schedule_available_action(action.id)

      {:active_completed, :idle} ->
        player_character_id = assigns.player_character_id
        {:ok, ecs_combatant_entity} = Tarragon.Ecspanse.Battles.Api.find_combatant_entity_by_user_character_id(player_character_id)

        [action_entity] = Lookup.list_descendants(ecs_combatant_entity, Components.ActionState)
                          |> Enum.filter(
                               &match?({:ok, _}, Ecspanse.Query.fetch_tagged_component(&1, [:action, :dodge]))
                             )

        Tarragon.Ecspanse.Battles.Api.cancel_scheduled_action(action_entity.id)

      _ ->
        :ok
    end

    Map.merge(assigns, %{state_name => new_state, energy_state: new_energy_state})
  end

  def process_attack_action_event(event, state_name, assigns, params) do
    energy_state = assigns.energy_state
    grid_state = assigns.grid_state
    selected_character_id = params[:character_id]
    old_state = assigns[state_name]
    attack_target_options_character_ids = Enum.map(old_state.attack_target_options, &(&1.user_id))
    IO.inspect("process_attack_action_event #{event}" <>
               " selected_character_id: #{selected_character_id}" <>
               " attack_target_options: #{inspect(attack_target_options_character_ids, charlists: :as_lists)}")

    new_state =
      cond do
        event == "action_click" and old_state.state == :idle ->
          %{old_state | state: :active}

        event == "cancel_action" ->
          %{old_state | state: :idle}

        event == "character_click" and old_state.state == :active and selected_character_id in attack_target_options_character_ids ->
          %{old_state | state: :active_completed}

        true ->
          old_state
      end

    new_energy_state =
      case {old_state.state, new_state.state} do
        {:idle, :active} ->
          %{
            energy_state
          | current_energy: energy_state.current_energy - assigns[state_name].energy_cost
          }

        {_any, :idle} ->
          %{
            energy_state
          | current_energy: energy_state.current_energy + assigns[state_name].energy_cost
          }

        _ ->
          energy_state
      end

      new_grid_state = case {old_state.state, new_state.state} do
        {:idle, :active} ->
          player_character_id = assigns.player_character_id
          {character_location, _id} = Enum.find(grid_state.character_ids_by_locations, fn {_, id} -> id == player_character_id end)
          range = old_state.distance

          highlighted_cells = Tarragon.Ecspanse.MapParameters.neighbours(character_location, range)

          %{
            grid_state
          | attack_range_highlights: highlighted_cells
          }

        {:active, :active_completed} ->
          {:ok, selected_combatant} = Tarragon.Ecspanse.Battles.Api.find_combatant_by_user_character_id(selected_character_id)
          selected_character_location = selected_combatant.position
          %{
            grid_state
          | attack_range_highlights: [], attack_target_options: [], selected_attack_target: selected_character_id, selected_attack_location: selected_character_location
          }

        {_any, :idle} ->
          %{
            grid_state
          | attack_range_highlights: [], attack_target_options: [], selected_attack_target: nil, selected_attack_location: nil
          }

        _ ->
          grid_state
      end

    # State machine side effects
    case {old_state.state, new_state.state} do
      {:active, :active_completed} ->
        player_character_id = assigns.player_character_id
        {:ok, player_combatant_entity} = Tarragon.Ecspanse.Battles.Api.find_combatant_entity_by_user_character_id(player_character_id)
        {:ok, enemy_combatant_entity} = Tarragon.Ecspanse.Battles.Api.find_combatant_entity_by_user_character_id(selected_character_id)

        [action] =
          Lookup.list_descendants(player_combatant_entity, Components.ActionState)
          |> Enum.filter(
               &match?({:ok, _}, Ecspanse.Query.fetch_tagged_component(&1, [:action, :shooting]))
             )

        Tarragon.Ecspanse.Battles.Api.schedule_available_action(action.id)
        Tarragon.Ecspanse.Battles.Api.update_attack_target(player_combatant_entity.id, enemy_combatant_entity.id)

      {:active_completed, :idle} ->
        player_character_id = assigns.player_character_id
        {:ok, ecs_combatant_entity} = Tarragon.Ecspanse.Battles.Api.find_combatant_entity_by_user_character_id(player_character_id)

        [action_entity] = Lookup.list_descendants(ecs_combatant_entity, Components.ActionState)
                          |> Enum.filter(
                               &match?({:ok, _}, Ecspanse.Query.fetch_tagged_component(&1, [:action, :shooting]))
                             )

        Tarragon.Ecspanse.Battles.Api.cancel_scheduled_action(action_entity.id)

      _ ->
        :ok
    end


    Map.merge(assigns, %{state_name => new_state, energy_state: new_energy_state, grid_state: new_grid_state})
  end

#  defp process_click_attack_option(options, id) do
#    Enum.into(options, %{}, fn {i, option} ->
#      if "#{i}" == id do
#        {i, %{option | state: :active}}
#      else
#        {i, %{option | state: :idle}}
#      end
#    end)
#  end
#
#  defp process_select_attack_option(options, id) do
#    Enum.into(options, %{}, fn {i, option} ->
#      if "#{i}" == id do
#        {i, %{option | state: :active}}
#      else
#        {i, %{option | state: :translucent}}
#      end
#    end)
#  end

  def maybe_make_action_unavailable(action_state, energy_state) do
    result = cond do
      action_state.state == :idle and action_state.energy_cost > energy_state.current_energy ->
        %{action_state | state: :unavailable}

      action_state.state == :unavailable and
          action_state.energy_cost <= energy_state.current_energy ->
        %{action_state | state: :idle}

      true ->
        action_state
    end

    IO.inspect(
      "maybe_make_action_unavailable #{action_state.name} state: #{action_state.state} -> #{result.state} (cost: #{action_state.energy_cost} energy_available:#{energy_state.current_energy})"
    )

    result
  end

  def init_attack_action_state(cost, is_available, range, attack_target_options) do
    %{
      name: :attack_action_state,
      state: (if is_available, do: :idle, else: :unavailable),
      options: %{
        1 => %{id: 1, name: "Head", state: :hidden},
        2 => %{id: 2, name: "Body", state: :hidden},
        3 => %{id: 3, name: "Legs", state: :hidden}
      },
      distance: range,
      energy_cost: cost,
      attack_target_options: attack_target_options
    }
  end

  def init_dodge_action_state(cost, is_available) do
    %{
      name: :dodge_action_state,
      state: (if is_available, do: :idle, else: :unavailable),
      energy_cost: cost
    }
  end

  def init_step_action_state(cost, is_available) do
    %{
      name: :step_action_state,
      state: (if is_available, do: :idle, else: :unavailable),
      energy_cost: cost
    }
  end

  def init_energy_state(max_energy: max_energy, current_energy: current_energy, energy_regen: energy_regen) do
    %{
      name: :energy_state,
      max_energy: max_energy,
      current_energy: current_energy,
      energy_regen: energy_regen
    }
  end

  def get_player_character do
    participant =
      Tarragon.Repo.all(Tarragon.Battles.Participant)
      |> Enum.find(&(!&1.is_bot))
      |> Tarragon.Repo.preload([:user_character])

    participant.user_character
  end

  def get_player_character(id) do
    participant =
      Tarragon.Repo.all(Tarragon.Battles.Participant)
      |> Enum.find(&(&1.user_character_id == id))
      |> Tarragon.Repo.preload([:user_character])

      IO.inspect(participant)
    participant.user_character
  end

  def split_ally_enemy_teams(character_id, participants) do
    team_a_characters = team_a_characters(participants)
    team_b_characters = team_b_characters(participants)

    if character_id in Enum.map(team_a_characters, & &1.id) do
      {team_a_characters, team_b_characters}
    else
      {team_b_characters, team_a_characters}
    end
  end

  defp team_a_characters(participants) do
    participants
    |> Enum.filter(& &1.team_a)
    |> Enum.map(& &1.user_character)
  end

  defp team_b_characters(participants) do
    participants
    |> Enum.filter(& &1.team_b)
    |> Enum.map(& &1.user_character)
  end

  def distance(hex_a, hex_b) do
    Enum.max([abs(hex_a.x - hex_b.x), abs(hex_a.y - hex_b.y), abs(hex_a.z - hex_b.z)])
  end

  def hex_to_offset_pointy(hex) do
    x = hex.x + div(hex.y, 2)
    y = hex.y
    %{x: x, y: y}
  end

  def offset_to_hex_pointy(offset) do
    x = offset.x - div(offset.y, 2)
    y = offset.y
    z = -x - y
    %{x: x, y: y, z: z}
  end

  def offset_to_hex_flat(offset) do
    x = offset.x
    y = offset.y - div(offset.x, 2)
    z = -x - y
    %{x: x, y: y, z: z}
  end

  def generate_grid_circle_pointy(map_radius, cell_width) do
    ratio = 1.278688524590164

    cell_height = (cell_width / ratio) |> round

    inner_r = (cell_width / 2) |> round
    outer_r = (cell_height / 2) |> round

    cells =
      for x <- -map_radius..map_radius, y <- -map_radius..map_radius do
        offset_coords = %{x: x, y: y}
        hex_coordinates = offset_to_hex_pointy(offset_coords)

        if distance(%{x: 0, y: 0, z: 0}, hex_coordinates) <= map_radius do
          left = ((x + y * 0.5 - div(y, 2)) * (inner_r * 2)) |> round
          top = (y * outer_r * 1.5) |> round
          height = (outer_r * 2) |> round
          width = (inner_r * 2) |> round

          %{
            coord: offset_coords,
            hex_coords: hex_coordinates,
            left: left,
            top: top,
            width: width,
            height: height
          }
        else
          nil
        end
      end
      |> Enum.reject(&is_nil/1)

    %{
      name: "circular_grid_pointy",
      cells: cells,
      width: map_radius * cell_width,
      height: map_radius * cell_height
    }
  end

  def generate_grid_rectangle_pointy(height_cells, width_cells, cell_width) do
    ratio = 1.278688524590164

    cell_height = (cell_width / ratio) |> round

    inner_r = (cell_width / 2) |> round
    outer_r = (cell_height / 2) |> round

    cells =
      for x <- 0..(width_cells - 1), y <- 0..(height_cells - 1) do
        if rem(y, 2) != 0 and x == width_cells - 1 do
          # make it symmetrical by removing extra cells on the right on every odd row
          nil
        else
          offset_coords = %{x: x, y: y}
          hex_coordinates = offset_to_hex_pointy(offset_coords)

          left = ((x + y * 0.5 - div(y, 2)) * (inner_r * 2)) |> round
          top = (y * outer_r * 1.5) |> round
          height = cell_height
          width = cell_width

          %{
            coord: offset_coords,
            hex_coords: hex_coordinates,
            left: left,
            top: top,
            width: width,
            height: height
          }
        end
      end
      |> Enum.reject(&is_nil/1)

    %{
      name: "rectangular_grid_pointy",
      cells: cells,
      width: width_cells * cell_width,
      height: height_cells * cell_height
    }
  end

  def generate_grid_circle_flat(map_radius, cell_width) do
    ratio = 1.6

    cell_height = (cell_width / ratio) |> round

    inner_r = (cell_height / 2) |> round
    outer_r = (cell_width / 2) |> round

    cells =
      for x <- -map_radius..map_radius, y <- -map_radius..map_radius do
        offset_coords = %{x: x, y: y}
        hex_coordinates = offset_to_hex_flat(offset_coords)

        if distance(%{x: 0, y: 0, z: 0}, hex_coordinates) <= map_radius and (x <= 3 and x >= -3) do
          left = (x * outer_r * 1.5) |> round
          top = ((y + x * 0.5 - div(x, 2)) * inner_r * 2) |> round
          height = cell_height
          width = cell_width

          %{
            coord: offset_coords,
            hex_coords: hex_coordinates,
            left: left,
            top: top,
            width: width,
            height: height
          }
        else
          nil
        end
      end
      |> Enum.reject(&is_nil/1)

    map_diameter = Enum.map(-map_radius..map_radius, & &1) |> length
    width = map_diameter * 1.5 * cell_width
    height = map_diameter * cell_height
    %{name: "circular_grid_flat", cells: cells, width: width, height: height}
  end

  def generate_grid_rectangle_flat(height_cells, width_cells, cell_width) do
    ratio = 1.278688524590164

    cell_height = (cell_width * ratio) |> round

    inner_r = (cell_height / 2) |> round
    outer_r = (cell_width / 2) |> round

    cells =
      for x <- 0..(width_cells - 1), y <- 0..(height_cells - 1) do
        if rem(x, 2) != 0 and y == height_cells - 1 do
          # make it symmetrical by removing extra cells on the right on every odd row
          nil
        else
          offset_coords = %{x: x, y: y}
          hex_coordinates = offset_to_hex_flat(offset_coords)

          left = (x * outer_r * 1.5) |> round
          top = ((y + x * 0.5 - div(x, 2)) * inner_r * 2) |> round
          height = cell_height
          width = cell_width

          %{
            coord: offset_coords,
            hex_coords: hex_coordinates,
            left: left,
            top: top,
            width: width,
            height: height
          }
        end
      end
      |> Enum.reject(&is_nil/1)

    %{
      name: "rectangular_grid_flat",
      cells: cells,
      width: width_cells * cell_width,
      height: height_cells * cell_height
    }
  end
end
