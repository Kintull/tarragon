defmodule Tarragon.Message.ChatRoomMember do
  use Ecto.Schema
  alias Tarragon.Accounts.UserCharacter
  alias Tarragon.Message.ChatRoom
  alias Tarragon.Message.UserCharacterMessage

  schema "chat_room_member" do

    belongs_to :chat_room, ChatRoom
    belongs_to :user_characters, UserCharacter
    has_many :user_character_message, UserCharacterMessage

  timestamps()

  end
end
