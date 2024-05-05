defmodule TarragonWeb.PageLive.BattleScreenV2 do
  use TarragonWeb, :live_view

  alias Tarragon.Battles

  def mount(_params, _, socket) do
    {c_loc, e_loc, r_loc} =
      if connected?(socket) do
        viewport_width = socket.private.connect_params["viewport"]["width"]
        viewport_height = socket.private.connect_params["viewport"]["height"] - 55 - 165

        calculate_locations(viewport_width, viewport_height)
      else
        character_params = %{bottom: 0, left: 0, height: 0, width: 0}
        enemy_params = %{bottom: 0, left: 0, height: 0, width: 0}
        range_params = %{bottom: 0, left: 0, height: 0, width: 0}
        {character_params, enemy_params, range_params}
      end
      |> IO.inspect()

    character = get_player_character()
    room = Battles.impl().get_character_active_room(character.id)
    {ally_team, enemy_team} = split_ally_enemy_teams(character.id, room.participants)
    selected_enemy = hd(enemy_team)

    seconds_left = 20

    battle_bonus_map =
      Enum.map(room.participants, fn participant ->
        {participant.user_character_id,
         Battles.impl().build_character_bonuses(participant.user_character_id)}
      end)
      |> Enum.into(%{})

    avatars_by_ids =
      Enum.into(room.participants, %{}, fn participant ->
        {participant.user_character_id, participant.user_character.avatar_url}
      end)

    max_health_points_by_ids =
      Enum.into(room.participants, %{}, fn participant ->
        {participant.user_character_id,
         battle_bonus_map[participant.user_character_id].max_health}
      end)

    current_health_points_by_ids =
      Enum.into(room.participants, %{}, fn participant ->
        {participant.user_character_id,
         battle_bonus_map[participant.user_character_id].max_health}
      end)

    socket =
      socket
      |> assign(user_character_avatar: character.avatar_url)
      |> assign(ally_score: 0)
      |> assign(enemy_score: 0)
      |> assign(seconds_left: seconds_left)
      |> assign(player_character_id: character.id)
      |> assign(target_character_id: selected_enemy.id)
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
          :energy_state
        ]
      )
      |> assign(
        action_to_state_name: %{
          "attack" => :attack_action_state,
          "dodge" => :dodge_action_state,
          "step" => :step_action_state
        }
      )
      |> assign(attack_action_state: init_attack_action_state())
      |> assign(dodge_action_state: init_dodge_action_state())
      |> assign(step_action_state: init_step_action_state())
      |> assign(energy_state: init_energy_state())
      |> assign(c_loc: c_loc)
      |> assign(e_loc: e_loc)
      |> assign(r_loc: r_loc)
      |> assign(bg_tile_size: 200)

    {:ok, socket, layout: false}
  end

  def handle_event("resized", %{"height" => 740, "width" => 360} = params, socket) do
    IO.inspect("handle_event(resized/battle_screen_v2)")
    viewport_width = params["width"]
    viewport_height = params["height"] - 55 - 165
    {c_loc, e_loc, r_loc} = calculate_locations(viewport_width, viewport_height)

    socket =
      socket
      |> assign(c_loc: c_loc)
      |> assign(e_loc: e_loc)
      |> assign(r_loc: r_loc)

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
    IO.inspect(socket.assigns.energy_state)
    {:noreply, socket}
  end

  def handle_event("attack_option_click" = event, %{"option_id" => option_id}, socket) do
    updated_states =
      process_action_event(
        event,
        :attack_action_state,
        Map.take(socket.assigns, socket.assigns.action_related_keys),
        %{option_id: option_id}
      )

    socket = Enum.reduce(updated_states, socket, fn {k, v}, acc -> assign(acc, k, v) end)
    {:noreply, socket}
  end

  def handle_event("attack_option_select" = event, %{"option_id" => option_id}, socket) do
    updated_states =
      process_action_event(
        event,
        :attack_action_state,
        Map.take(socket.assigns, socket.assigns.action_related_keys),
        %{option_id: option_id}
      )

    socket = Enum.reduce(updated_states, socket, fn {k, v}, acc -> assign(acc, k, v) end)
    IO.inspect(socket.assigns.energy_state)
    {:noreply, socket}
  end

  def init_attack_action_state() do
    %{
      name: :attack_action_state,
      state: :idle,
      options: %{
        1 => %{id: 1, name: "Head", state: :hidden},
        2 => %{id: 2, name: "Body", state: :hidden},
        3 => %{id: 3, name: "Legs", state: :hidden}
      },
      energy_cost: 1
    }
  end

  def init_dodge_action_state() do
    %{
      name: :dodge_action_state,
      state: :idle,
      energy_cost: 1
    }
  end

  def init_step_action_state() do
    %{
      name: :step_action_state,
      state: :idle,
      energy_cost: 1
    }
  end

  def init_energy_state do
    %{
      name: :energy_state,
      max_energy: 3,
      current_energy: 3,
      energy_regen: 2
    }
  end

  def process_action_event(event, state_name, assigns, params \\ %{}) do
    new_states =
      case state_name do
        :attack_action_state -> process_attack_action_event(event, state_name, assigns, params)
        :dodge_action_state -> process_step_and_dodge_action_event(event, state_name, assigns)
        :step_action_state -> process_step_and_dodge_action_event(event, state_name, assigns)
      end

    # based on new energy state, update action states, enable/disable actions
    new_energy_state = new_states.energy_state
    all_action_state_keys = Map.values(assigns.action_to_state_name)

    Enum.into(
      all_action_state_keys,
      new_states,
      fn action_name ->
        {action_name, maybe_make_action_unavailable(new_states[action_name], new_energy_state)}
      end
    )
  end

  def process_step_and_dodge_action_event(event, state_name, assigns) do
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

        {:active, :idle} ->
          %{
            energy_state
            | current_energy: energy_state.current_energy + assigns[state_name].energy_cost
          }

        _ ->
          energy_state
      end

    Map.merge(assigns, %{state_name => new_state, energy_state: new_energy_state})
  end

  def process_attack_action_event(event, state_name, assigns, params) do
    IO.inspect(event)
    energy_state = assigns.energy_state
    old_state = assigns[state_name]

    new_state =
      cond do
        event == "action_click" and old_state.state == :idle ->
          new_options = process_click_attack_option(old_state.options, 1)
          %{old_state | state: :selected, options: new_options}

        event == "cancel_action" ->
          init_attack_action_state()

        event == "attack_option_click" and old_state.state == :selected ->
          new_options = process_click_attack_option(old_state.options, params.option_id)
          %{old_state | options: new_options}

        event == "attack_option_select" and old_state.state == :selected ->
          new_options = process_select_attack_option(old_state.options, params.option_id)
          %{old_state | state: :active, options: new_options}

        true ->
          old_state
      end

    new_energy_state =
      case {old_state.state, new_state.state} |> IO.inspect() do
        {:selected, :active} ->
          %{
            energy_state
            | current_energy: energy_state.current_energy - assigns[state_name].energy_cost
          }

        {:active, :idle} ->
          %{
            energy_state
            | current_energy: energy_state.current_energy + assigns[state_name].energy_cost
          }

        _ ->
          energy_state
      end

    Map.merge(assigns, %{state_name => new_state, energy_state: new_energy_state})
  end

  defp process_click_attack_option(options, id) do
    Enum.into(options, %{}, fn {i, option} ->
      if "#{i}" == id do
        {i, %{option | state: :selected}}
      else
        {i, %{option | state: :idle}}
      end
    end)
  end

  defp process_select_attack_option(options, id) do
    Enum.into(options, %{}, fn {i, option} ->
      if "#{i}" == id do
        {i, %{option | state: :active}}
      else
        {i, %{option | state: :translucent}}
      end
    end)
  end

  def maybe_make_action_unavailable(action_state, energy_state) do
    IO.inspect(
      "maybe_make_action_unavailable #{action_state.name} #{action_state.state} #{action_state.energy_cost} #{energy_state.current_energy}"
    )

    cond do
      action_state.state == :idle and action_state.energy_cost > energy_state.current_energy ->
        %{action_state | state: :unavailable}

      action_state.state == :unavailable and
          action_state.energy_cost <= energy_state.current_energy ->
        %{action_state | state: :idle}

      true ->
        action_state
    end
  end

  def get_player_character do
    participant =
      Tarragon.Repo.all(Tarragon.Battles.Participant)
      |> List.first()
      |> Tarragon.Repo.preload([:user_character])

    participant.user_character
  end

  def hard_reset_battles do
    Seeder.delete_all_participants_and_rooms()
    ally_characters = for _ <- 1..3, do: Seeder.create_character_with_items()
    enemy_characters = for _ <- 1..3, do: Seeder.create_character_with_items()
    Seeder.create_battle_room_with_participants(ally_characters, enemy_characters)

    ally_characters |> List.first()
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

  def split_ally_enemy_teams(character_id, participants) do
    team_a_characters = team_a_characters(participants)
    team_b_characters = team_b_characters(participants)

    if character_id in Enum.map(team_a_characters, & &1.id) do
      {team_a_characters, team_b_characters}
    else
      {team_b_characters, team_a_characters}
    end
  end

  # defp show_victory?(room, current_participant) do
  #   (room.winner_team == :team_a and current_participant.team_a) ||
  #     (room.winner_team == :team_b and current_participant.team_b)
  # end

  # def show_defeat?(room, current_participant) do
  #   (room.winner_team == :team_a and current_participant.team_b) ||
  #     (room.winner_team == :team_b and current_participant.team_a) ||
  #     room.winner_team == :draw
  # end

  def calculate_locations(viewport_width, viewport_height) do
    chunk = div(viewport_width, 6) |> round()
    width_tiles = (viewport_width / chunk) |> round()
    height_tiles = (viewport_height / chunk) |> round()

    character_image_aspect_ratio = 0.47
    character_width = (chunk * 1.2) |> round()
    character_height = (character_width / character_image_aspect_ratio) |> round()

    # header_height = 55
    # footer_height = 117
    # battle_area_height = viewport_height - header_height - footer_height
    # calculate player character bottom, left, hight, width
    # calculate enemy character top, left, height, width
    # calculate range highlight bottom, left, height, width

    # character is located in the bottom left corner
    player_bottom = chunk
    player_left = chunk
    player_height = character_height
    player_width = character_width

    character_params = %{
      bottom: player_bottom,
      left: player_left,
      height: player_height,
      width: player_width
    }

    # enemy is located in the top center
    enemy_bottom = (height_tiles / 2 * chunk) |> round()
    enemy_left = (width_tiles / 2 * chunk - character_width / 2) |> round()
    enemy_width = character_width
    enemy_height = character_height

    enemy_params = %{
      bottom: enemy_bottom,
      left: enemy_left,
      height: enemy_height,
      width: enemy_width
    }

    # attack_options
    #    attack_top = (height_tiles / 2 ) * chunk
    #    attack_left = enemy_left + enemy_width
    #    attack_params = %{bottom: attack_bottom, left: attack_left, height: attack_height, width: attack_width}

    # range left bottom corner is next to the player character legs and range top right corner is next to the enemy character chest
    range_bottom = player_bottom + player_height / 4
    range_left = player_left + player_width / 2
    range_top = enemy_bottom + enemy_height / 2
    range_right = enemy_left + enemy_width
    range_height = range_top - range_bottom
    range_width = range_right - range_left + chunk

    range_params = %{
      bottom: range_bottom,
      left: range_left,
      height: range_height,
      width: range_width
    }

    {character_params, enemy_params, range_params}
  end
end
