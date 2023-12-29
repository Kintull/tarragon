defmodule Tarragon.BattlesTest do
  use Tarragon.DataCase

  alias Tarragon.Battles

  describe "battle_rooms" do
    alias Tarragon.Battles.Room

    @date %{DateTime.now!("Etc/UTC") | year: 2001}
    @date2 %{DateTime.now!("Etc/UTC") | year: 2000}
    @valid_attrs %{
      ended_at: @date,
      started_at: @date,
      step: 42,
      turn_duration_sec: 42,
      max_participant: 2,
      awaiting_start: true
    }
    @update_attrs %{
      ended_at: @date2,
      started_at: @date2,
      step: 43,
      turn_duration_sec: 43,
      max_participant: 3,
      awaiting_start: false
    }

    def room_fixture(attrs \\ %{}) do
      {:ok, room} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Battles.create_room()

      room
    end

    test "list_battle_rooms/0 returns all battle_rooms" do
      room = room_fixture()
      assert Battles.list_battle_rooms() == [room]
    end

    test "get_room!/1 returns the room with given id" do
      room = room_fixture()
      assert Battles.get_room!(room.id) == room
    end

    test "create_room/1 with valid data creates a room" do
      assert {:ok, %Room{} = room} = Battles.create_room(@valid_attrs)
      assert %{year: 2001} = room.ended_at
      assert %{year: 2001} = room.started_at
      assert room.step == 42
      assert room.turn_duration_sec == 42
    end

    test "get_open_room_or_create/0 returns busiest rooms" do
      assert {:ok, %Room{id: _battle_room_id}} = Battles.create_room(@valid_attrs)
      assert {:ok, %Room{id: battle_room_id_2}} = Battles.create_room(@valid_attrs)
      assert {:ok, _} = Battles.create_participant(%{battle_room_id: battle_room_id_2})

      assert {:ok,
              %{
                id: ^battle_room_id_2,
                awaiting_start: true
              }} = Battles.get_open_room_or_create()
    end

    test "get_open_room_or_create/0 creates a new room when no rooms exist" do
      assert {:ok, %{id: _, awaiting_start: true}} = Battles.get_open_room_or_create()
    end

    test "update_room/2 with valid data updates the room" do
      room = room_fixture()
      assert {:ok, %Room{} = room} = Battles.update_room(room, @update_attrs)
      assert %{year: 2000} = room.ended_at
      assert %{year: 2000} = room.started_at
      assert room.step == 43
      assert room.turn_duration_sec == 43
    end

    test "delete_room/1 deletes the room" do
      room = room_fixture()
      assert {:ok, %Room{}} = Battles.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> Battles.get_room!(room.id) end
    end

    test "change_room/1 returns a room changeset" do
      room = room_fixture()
      assert %Ecto.Changeset{} = Battles.change_room(room)
    end
  end

  describe "battle_participant" do
    alias Tarragon.Battles.Participant

    @valid_attrs %{}
    @update_attrs %{}

    def participant_fixture(attrs \\ %{}) do
      {:ok, participant} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Battles.create_participant()

      participant
    end

    test "list_human_battle_participants/0 returns all battle_participant" do
      participant = participant_fixture()
      assert Battles.list_human_battle_participants() == [participant]
    end

    test "get_participant!/1 returns the participant with given id" do
      participant = participant_fixture()
      assert Battles.get_participant!(participant.id) == participant
    end

    test "create_participant/1 with valid data creates a participant" do
      assert {:ok, %Participant{}} = Battles.create_participant(@valid_attrs)
    end

    test "update_participant/2 with valid data updates the participant" do
      participant = participant_fixture()
      assert {:ok, %Participant{}} = Battles.update_participant(participant, @update_attrs)
    end

    test "delete_participant/1 deletes the participant" do
      participant = participant_fixture()
      assert {:ok, %Participant{}} = Battles.delete_participant(participant)
      assert_raise Ecto.NoResultsError, fn -> Battles.get_participant!(participant.id) end
    end

    test "change_participant/1 returns a participant changeset" do
      participant = participant_fixture()
      assert %Ecto.Changeset{} = Battles.change_participant(participant)
    end
  end
end
