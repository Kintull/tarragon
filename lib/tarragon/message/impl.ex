defmodule Tarragon.Message.Impl do

  # alias Ecto.Repo
  alias Tarragon.Message.UserCharacterMessage
  alias Tarragon.Repo
  alias Tarragon.Accounts.UserCharacter 
  import Ecto.Query
  


  # get all messages
  def get_messages do
    UserCharacterMessage
    |> Repo.all()
  
  end

  # get user message based on character
  # geting specific messages and sender
  #
  def get_all_messages_senders do
     
    query = from u in UserCharacterMessage,
      join: c in UserCharacter , on: c.id == u.user_character_id, 
      select: [u.message, c.nickname, c.avatat_url]

    Repo.all(query)
    

  end

  @doc """
    the sender/ character should have a permanent id

    here you insert a insert a message to that id
    so there is no creation of that another id to to represent the sender
    so the sender id should will act as foreign key to the userCharactermessge table
    """

    def insert_message(sender_id, message) do
      %UserCharacterMessage{
        message: message,
        user_character_id: sender_id
      } 
      |> Repo.insert()

    end 

  
end
