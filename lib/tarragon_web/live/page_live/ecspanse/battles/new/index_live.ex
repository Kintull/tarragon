defmodule TarragonWeb.PageLive.Ecspanse.Battles.New.IndexLive do
  alias Tarragon.Ecspanse.Lobby.LobbyGame
  alias Tarragon.Ecspanse.Lobby.LobbyGamesAgent
  alias Tarragon.Ecspanse.Lobby.GameParameters

  use TarragonWeb, :live_view

  def mount(_params, _session, socket) do
    socket
    |> assign_new(
      :form,
      fn ->
        GameParameters.new(%{id: System.monotonic_time()})
        |> GameParameters.changeset()
        |> to_form()
      end
    )
    |> ok()
  end

  def handle_event("save", %{"game_parameters" => game_parameters}, socket) do
    changeset =
      %GameParameters{id: System.monotonic_time()}
      |> GameParameters.changeset(game_parameters)

    socket =
      case changeset.errors do
        [] ->
          game_parameters =
            changeset
            |> Ecto.Changeset.apply_changes()

          %LobbyGame{
            id: game_parameters.id,
            game_parameters: game_parameters
          }
          |> LobbyGamesAgent.put()

          socket |> push_navigate(to: ~p"/ecspanse/battles/lobby/#{game_parameters.id}")

        _ ->
          form =
            changeset
            |> Map.put(:action, :validate)
            |> to_form()

          socket |> assign(:form, form)
      end

    socket |> noreply()
  end

  def handle_event("validate", %{"game_parameters" => game_parameters}, socket) do
    form =
      %GameParameters{id: System.monotonic_time()}
      |> GameParameters.changeset(game_parameters)
      |> Map.put(:action, :validate)
      |> to_form()

    socket |> assign(:form, form) |> noreply()
  end

  def handle_event(event, params, socket) do
    IO.inspect(event, label: "#{__MODULE__} unhandled event")
    IO.inspect(params, label: "#{__MODULE__} unhandled params")
    noreply(socket)
  end

  def handle_info(msg, socket) do
    IO.inspect(msg, label: "#{__MODULE__} unhandled info")
    noreply(socket)
  end
end
