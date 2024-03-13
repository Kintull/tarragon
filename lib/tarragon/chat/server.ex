defmodule Tarragon.Chat.Server do
  use GenServer

  alias Tarragon.Message.Impl

  def start_link(_) do
    messages_in_db = Impl.get_all_messages_senders()
    GenServer.start_link(__MODULE__, messages_in_db, name: __MODULE__)
  end

  # for sending messages to db
  def messages_to_db(pid, message) do
    GenServer.cast(pid, {:messages_to_db, message})
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
  def handle_cast({:messages_to_db, message}, messages_in_db) do
    # messages = [message | messages() ]
    Impl.insert_message(message.sender_id, message.message)

    Phoenix.PubSub.broadcast(Tarragon.PubSub, "message_events", :message_created)
    {:noreply, messages_in_db}
  end

  # search messages from db
  def handle_call(:messages_from_db, _from, messages) do
    messages_in_db = Impl.get_all_messages_senders()
    {:reply, messages, messages_in_db}
  end
end
