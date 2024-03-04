defmodule Tarragon.Message.UserCharacterMessage do
  use Ecto.Schema
  alias Tarragon.Accounts.UserCharacter
  alias Tarragon.Message.ChatRoomMember
  alias Tarragon.Message.ChatRoom

  schema "user_character_messages" do

  field :message, :string
  belongs_to :user_character, UserCharacter
  belongs_to :chat_rooms, ChatRoom
  # belongs_to :chat_room_member, ChatRoomMember
  timestamps()

  end
end