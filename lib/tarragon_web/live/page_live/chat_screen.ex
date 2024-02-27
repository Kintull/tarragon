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
  def sent_messages do
    []
  end
  # query the sender of the message
  def mount(_params, %{"user_id" => user_id}, socket) do
    message_inbox =  GenServer.call(Server, :messages_from_db)
    IO.inspect(message_inbox)
    # i have to insert the message of this given id
    socket = assign(socket,
      message_inbox: message_inbox,
      sent_messages: sent_messages(),
      the_message: "",
      user_id: user_id
    )
    
    {:ok, socket, layout: false}
  end

  # event for sending message
  # the event in the input should be passed  then to be displayed on the sent message tag

  def handle_event("send_message", %{"message" => message}, socket) do
    %Phoenix.LiveView.Socket{assigns: %{user_id: user_id}} = socket

    


    IO.puts("clicked")
    IO.inspect(message)
    IO.inspect(socket)

    # insert the message
    Impl.insert_message(user_id, message)
    IO.put("message sent")
    {:noreply, socket}
  end

  def handle_event("send_message", _params, socket) do
    # insert the 

    {:noreply, socket}
  end
end
