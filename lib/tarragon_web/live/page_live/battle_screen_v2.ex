defmodule TarragonWeb.PageLive.BattleScreenV2 do
  use TarragonWeb, :live_view

  alias Tarragon.Accounts
  alias Tarragon.Inventory
  alias Tarragon.Battles

  def mount(_params, _, socket) do

    {c_loc, e_loc, r_loc} =
      if connected?(socket) do
        viewport_width = socket.private.connect_params["viewport"]["width"]
        viewport_height = socket.private.connect_params["viewport"]["height"] - 55 - 165
        {character_params, enemy_params, range_params} = calculate_locations(viewport_width, viewport_height)
      else
        character_params = %{bottom: 0, left: 0, height: 0, width: 0}
        enemy_params = %{bottom: 0, left: 0, height: 0, width: 0}
        range_params = %{bottom: 0, left: 0, height: 0, width: 0}
        {character_params, enemy_params, range_params}
      end |> IO.inspect

    character = get_player_character()
    participant = Battles.impl().get_active_participant(character)
    room = Battles.impl().get_character_active_room(character.id)
    {ally_team, enemy_team} = split_ally_enemy_teams(character.id, room.participants)
    selected_enemy = hd(enemy_team)

#    submitted_players_count = Battles.impl().count_submitted(room.id)
#    current_player_eliminated =
#      Enum.find(room.participants, &(&1.user_character_id == character.id)).eliminated
#    show_victory = show_victory?(room, participant)
#    show_defeat = show_defeat?(room, participant)

    seconds_left = 20

    battle_bonus_map = Enum.map(room.participants, fn participant ->
      {participant.user_character_id,
        Battles.impl().build_character_bonuses(participant.user_character_id)}
    end)
    |> Enum.into(%{})

    avatars_by_ids = Enum.into(room.participants, %{}, fn participant ->
      {participant.user_character_id, participant.user_character.avatar_url}
    end)

    max_health_points_by_ids = Enum.into(room.participants, %{}, fn participant ->
      {participant.user_character_id, battle_bonus_map[participant.user_character_id].max_health}
    end)

    current_health_points_by_ids = Enum.into(room.participants, %{}, fn participant ->
      {participant.user_character_id, battle_bonus_map[participant.user_character_id].max_health}
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
      |> assign(step_card_state: :idle)
      |> assign(attack_card_state: :idle)
      |> assign(dodge_card_state: :idle)
      |> assign(attack_action_state: init_attack_action_state())
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

  def handle_event("action_click", %{"action" => action} = params, socket) do
    case action do
      "step" ->
        new_state = if socket.assigns[:step_card_state] == "idle", do: "selected", else: socket.assigns[:step_card_state]
        {:noreply, assign(socket, step_card_state: new_state)}

      "attack" ->
        socket = assign(socket, attack_action_state: update_attack_state("action_click", socket.assigns.attack_action_state))
        {:noreply, socket}

      "dodge" ->
        new_state = if socket.assigns[:dodge_card_state] == "idle", do: "selected", else: socket.assigns[:step_card_state]
        {:noreply, assign(socket, dodge_card_state: new_state)}
    end
  end

  def handle_event("cancel_action", %{"action" => action}, socket) do
    case action do
      "step" -> {:noreply, assign(socket, step_card_state: "idle")}
      "attack" ->
        socket = assign(socket, attack_action_state: update_attack_state("cancel_action", socket.assigns.attack_action_state))
        {:noreply, socket}
      "dodge" -> {:noreply, assign(socket, dodge_card_state: "idle")}
    end
  end

  def handle_event("attack_option_click", %{"option_id" => option_id}, socket) do
    attack_action_state = socket.assigns.attack_action_state
    socket = assign(socket, attack_action_state: update_attack_state("attack_option_click", option_id, attack_action_state))
    {:noreply, socket}
  end

  def handle_event("attack_option_select", %{"option_id" => option_id}, socket) do
    attack_action_state = socket.assigns.attack_action_state
    socket = assign(socket, attack_action_state: update_attack_state("attack_option_select", option_id, attack_action_state))
    {:noreply, socket}
  end

  def init_attack_action_state() do
    %{
      state: :idle,
      options: %{
        1 => %{id: 1, name: "Head", state: :hidden},
        2 => %{id: 2, name: "Body", state: :hidden},
        3 => %{id: 3, name: "Legs", state: :hidden}
      }
    }
  end

  def update_attack_state("action_click", %{state: state} = action_state) do
    case state do
      :idle ->
        options = Enum.into(action_state.options, %{}, fn {i, option} ->
          {i, %{option | state: :idle}}
        end)
        %{ action_state | state: :selected, options: options }
      :selected -> action_state
      :active -> action_state
    end
  end

  def update_attack_state("cancel_action", %{state: state}) do
    case state do
      :idle -> init_attack_action_state()
      :selected -> init_attack_action_state()
      :active -> init_attack_action_state()
    end
  end

  def update_attack_state("attack_option_click", id, %{state: state} = action_state) do
    case state do
      :selected ->
        updated_options = Enum.into(action_state.options, %{}, fn {i, option} ->
          if "#{i}" == id do
            {i, %{option | state: :selected}}
          else
            {i, %{option | state: :idle}}
          end
        end) |> IO.inspect()

        %{action_state | options: updated_options}

      :idle -> action_state
      :active -> action_state
    end
  end

  def update_attack_state("attack_option_select", id, %{state: state} = action_state) do
    case state do
      :selected ->
        updated_options = Enum.into(action_state.options, %{}, fn {i, option} ->
          if "#{i}" == id do
            {i, %{option | state: :active}}
          else
            {i, %{option | state: :translucent}}
          end
        end) |> IO.inspect()

        %{action_state | options: updated_options, state: :active}

      :idle -> action_state
      :active -> action_state
    end
  end

  def get_player_character do
    participant  = Tarragon.Repo.all(Tarragon.Battles.Participant)
    |> List.first()
    |> Tarragon.Repo.preload([:user_character])

    participant.user_character
  end

  def hard_reset_battles do
    Seeder.delete_all_participants_and_rooms()
    ally_characters = for x <- 1..3, do: Seeder.create_character_with_items()
    enemy_characters = for x <- 1..3, do: Seeder.create_character_with_items()
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

  defp show_victory?(room, current_participant) do
    (room.winner_team == :team_a and current_participant.team_a) ||
      (room.winner_team == :team_b and current_participant.team_b)
  end

  def show_defeat?(room, current_participant) do
    (room.winner_team == :team_a and current_participant.team_b) ||
      (room.winner_team == :team_b and current_participant.team_a) ||
      room.winner_team == :draw
  end

  def calculate_locations(viewport_width, viewport_height) do
    chunk = div(viewport_width, 6) |> round()
    width_tiles = (viewport_width / chunk) |> round()
    height_tiles = (viewport_height / chunk) |> round()

    character_image_aspect_ratio = 0.47
    character_width = (chunk * 1.2) |> round()
    character_height = (character_width / character_image_aspect_ratio) |> round()

    header_height = 55
    footer_height = 165
    battle_area_height = viewport_height - header_height - footer_height
    # calculate player character bottom, left, hight, width
    # calculate enemy character top, left, height, width
    # calculate range highlight bottom, left, height, width

    # character is located in the bottom left corner
    player_bottom = chunk
    player_left = chunk
    player_height = character_height
    player_width = character_width
    character_params = %{bottom: player_bottom, left: player_left, height: player_height, width: player_width}

    # enemy is located in the top center
    enemy_bottom = ((height_tiles / 2 ) * chunk) |> round()
    enemy_left = ((width_tiles / 2) * chunk - character_width / 2) |> round()
    enemy_width = character_width
    enemy_height = character_height
    enemy_params = %{bottom: enemy_bottom, left: enemy_left, height: enemy_height, width: enemy_width}

    # attack_options
#    attack_top = (height_tiles / 2 ) * chunk
#    attack_left = enemy_left + enemy_width
#    attack_params = %{bottom: attack_bottom, left: attack_left, height: attack_height, width: attack_width}

    # range left bottom corner is next to the player character legs and range top right corner is next to the enemy character chest
    range_bottom = player_bottom + player_height/4
    range_left = player_left + player_width / 2
    range_top = enemy_bottom + enemy_height / 2
    range_right = enemy_left + enemy_width
    range_height = range_top - range_bottom
    range_width = range_right - range_left + chunk
    range_params = %{bottom: range_bottom, left: range_left, height: range_height, width: range_width}

    {character_params, enemy_params, range_params}
  end


end
