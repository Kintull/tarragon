defmodule TarragonWeb.PageLive.ChatScreen do
  use TarragonWeb, :live_view

  # sample of message to be sent
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

  # this will hold the message that will you will send to the chat
  def sent_messages do
    []
  end
  def mount(_params, _session, socket) do
    socket = assign(socket,
      message_inbox: messages(),
      sent_messages: sent_messages(),
      the_message: "")
    {:ok, socket, layout: false}
  end

  # event for sending message
  # the event in the input should be passed  then to be displayed on the sent message tag

  def handle_event("send_message", %{"message" => message}, socket) do
    IO.puts("clicked")
    IO.inspect(message)
    socket = assign(socket, the_message: sent_messages() ++ message)
    {:noreply, socket}
  end

  def handle_event("send_message", _unsigned_params, socket) do
    IO.puts("clicked no message sent")
    socket = assign(socket, the_message: "empty")

    {:noreply, socket}
  end
end
