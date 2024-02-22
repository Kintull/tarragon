defmodule Tarragon.Chat.Server do
  use GenServer

  alias Tarragon.Message.Impl

  # example messages
  def messages do
    [
      %{
        sender: "moses",
        message: "welcom to this fight i won the last match"
      },

      %{
        sender: "kim",
        message: "am doing it again"
      },

      %{
        sender: "Tara",
        message: "i am not loosing the fight again"
      }
    ]
  end

def start_link  do
  messages_in_db = Impl.get_messages()
  GenServer.start_link(__MODULE__,  messages_in_db, name: __MODULE__)
end
# for sending messages to db
def  messages_to_db(pid, message) do
  GenServer.cast(pid,{ :messages_to_db, message})
end

# this is for accessing message from db
def messages_from_db(pid) do

  GenServer.call(pid, :messages_from_db)
end



def init(messages_in_db) do
  IO.inspect(messages_in_db)
  {:ok, messages_in_db}
end

# this will send messages to db
def handle_cast({:messages_to_db, message}, _from, message) do
  messages = [message | messages() ]
  {:noreply, messages}
end

# search messages from db
def handle_call(:messages_from_db, _from, messages) do
  {:reply, messages, messages}
end

end
