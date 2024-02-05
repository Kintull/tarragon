defmodule Tarragon.Message.ChatRoom do
  use Ecto.Schema
  alias Tarragon.Message.UserCharacterMessage
  alias Tarragon.Message.ChatRoomMember

  schema "chat_room" do

    field :title,:string
    has_many :chat_room_member, ChatRoomMember
    has_many :user_character_message, UserCharacterMessage

  timestamps()
  end
end
