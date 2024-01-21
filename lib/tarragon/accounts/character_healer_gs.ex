defmodule Tarragon.Accounts.CharacterHealer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, %{bots: %{}}, {:continue, :load_characters}}
  end

  def handle_continue(:load_characters, _state) do
    IO.inspect("CharacterHealerGs load_characters")
    user_characters = Tarragon.Accounts.impl().list_all_healing_user_characters!()
    Process.send_after(self(), :heal_characters, 1000)
    Process.send_after(self(), :reload_characters, 5000)
    {:noreply, %{user_characters: user_characters}}
  end

  def handle_info(:heal_characters, %{user_characters: user_characters}) do
    user_characters =
      Enum.map(user_characters, fn user_character ->
        if user_character.current_health < user_character.max_health do
          updated_character = %{
            user_character
            | current_health: user_character.current_health + 1
          }

          {:ok, _} =
            Tarragon.Accounts.impl().update_user_character(user_character, %{
              current_health: user_character.current_health + 1
            })

          IO.inspect(updated_character.current_health)
          updated_character
        else
          user_character
        end
      end)

    Process.send_after(self(), :heal_characters, 1000)

    {:noreply, %{user_characters: user_characters}}
  end

  def handle_info(:reload_characters, %{user_characters: _}) do
    user_characters = Tarragon.Accounts.impl().list_all_healing_user_characters!()

    Process.send_after(self(), :reload_characters, 5000)

    {:noreply, %{user_characters: user_characters}}
  end
end
