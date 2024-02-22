defmodule Tarragon.Message.Impl do

  # alias Ecto.Repo
  alias Tarragon.Message.UserCharacterMessage
  alias Tarragon.Repo
  
  
  # get all messages
  def get_messages do
    UserCharacterMessage
    |> Repo.all()
  
  end

  # get user message based on character
  #
end
