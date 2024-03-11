defmodule TarragonWeb.PageLive.ChatScreen do
  use TarragonWeb, :live_view

  use GenServer
  alias Tarragon.Chat.Server

  alias Tarragon.Accounts

  alias Tarragon.Message.Impl

  # sample of message to be sent
  @doc """
  def messages do
    [
      %{
        sender: "moses",
        message: "welcom eto this fight i won the last match"
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
  """

  # this will hold the message that will you will send to the chat
  def send_message_to_db(user_id, message) do
    message = %{sender_id: user_id, message: message}
    GenServer.cast(Server, {:messages_to_db, message})
  
  end

  defp message_from_db do 

    messages = GenServer.call(Server, :messages_from_db)

    broadcast(messages)
    messages
  end

  defp messages_from_sender do

    GenServer.call(Server, :messages_from_db)
  end

  # query the sender of the message
  # on mount this should subscribe
  def mount(_params, %{"user_id" => user_id}, socket) do
    Phoenix.PubSub.subscribe(Tarragon.PubSub, "all_messages")

    message_inbox =  message_from_db()
    IO.inspect(message_inbox)

    # i have to insert the message of this given id
    socket = assign(socket,
      message_inbox: message_inbox,
      sent_messages: message_from_db(),
      the_message: "",
      user_id: user_id
    )
    
    {:ok, socket, layout: false}
  end

  #hangling the subscription of the messages
  @impl true
  def handle_info({:all_messages, all_messages}, socket) do
  

    socket = assign(socket, 

      sent_messages: all_messages
    )
    IO.inspect(socket)
    {:noreply, socket}

  end

  defp broadcast(messages) do
    
    Phoenix.PubSub.broadcast(Tarragon.PubSub, "all_messages", {:all_messages, messages})
  end

  # event for sending message
  # the event in the input should be passed  then to be displayed on the sent message tag

  def handle_event("send_message", %{"message" => message}, socket) do
   # %Phoenix.LiveView.Socket{assigns: %{user_id: user_id}} = socket
    user_id = socket.assigns[:user_id]

    
    # send message
    send_message_to_db(user_id, message)
    messages = message_from_db
    broadcast(messages)

    IO.puts("clicked")

      
    {:noreply, socket}
  end

  def handle_event("send_message", _params, socket) do

    {:noreply, socket}
  end
  
end
