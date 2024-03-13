defmodule Tarragon.Message.Impl do
  # alias Ecto.Repo
  alias Tarragon.Message.ChatMessage 
  alias Tarragon.Message.UserCharacterMessage
  alias Tarragon.Repo
  alias Tarragon.Accounts.UserCharacter
  import Ecto.Query

  # get user message based on character
  # geting specific messages and sender
  # and broadcasting all the messages
  @spec get_all_messages_senders() :: list(%{message: String.t(), sender: String.t()})
  def get_all_messages_senders do
    query =
      from u in UserCharacterMessage,
        join: c in UserCharacter,
        on: c.id == u.user_character_id,
        select: %ChatMessage{
          nickname: c.nickname,
          message: u.message,
          avatar_url: c.avatar_url,
          sender_character_id: c.id,
          room_id: u.chat_room_id
        }

    Repo.all(query)
  end



  @doc """
  the sender/ character should have a permanent id

  here you insert a insert a message to that id
  so there is no creation of that another id to to represent the sender
  so the sender id should will act as foreign key to the userCharactermessge table
  """

  # @spec insert_message(sender_id: integer, message: string) :: {:ok, %UserCharacterMessage.t())

  # @spec insert_message(sender_id: integer, message: string) :: {:ok, %UserCharacterMessage.t()}
  def insert_message(sender_id, message) do
    %UserCharacterMessage{
      message: message,
      user_character_id: sender_id
    }
    |> Repo.insert()
  end

  @doc """



  """
  @spec get_my_messages(integer()) :: {:ok, list(%{sender: String.t(), message: String.t()})}
  def get_my_messages(user_id) do
    query =
      from u in UserCharacterMessage,
        join: c in UserCharacter,
        on: c.id == ^user_id,
        select: [c.nickname, u.message]

    Repo.all(query)
    |> Enum.map(fn x ->
      %{
        sender: Enum.at(x, 0),
        message: Enum.at(x, 1)
      }
    end)
  end

  # getting message
end
