defmodule TarragonWeb.Router do
  use TarragonWeb, :router
  import PhoenixStorybook.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TarragonWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin do
    plug :put_root_layout, html: {TarragonWeb.Layouts, :admin_root}
  end

  scope "/" do
    storybook_assets()
  end

  scope "/", TarragonWeb do
    pipe_through :browser

    get "/login/:user_id", AuthenticationController, :index

    #    get "/", PageController, :home
    live "/", PageLive.Index, :index
    live "/game_screen", PageLive.GameScreen, :game_screen
    live "/player_screen", PageLive.PlayerScreen, :player_screen
    live "/battle_screen", PageLive.BattleScreen, :battle_screen
    live "/backpack_screen", PageLive.BackpackScreen, :backpack_screen
    live "/battle_screen_v2", PageLive.BattleScreenV2, :battle_screen
    live "/battle_screen_v3", PageLive.BattleScreenV3, :battle_screen
    live "/lobby", PageLive.Lobby, :lobby
    live_storybook("/storybook", backend_module: TarragonWeb.Storybook)

    # ecspanse battles
    live "/ecspanse/battles/new", PageLive.Ecspanse.Battles.New.IndexLive
    live "/ecspanse/battles/lobby", PageLive.Ecspanse.Battles.Lobby.IndexLive
    live "/ecspanse/battles/lobby/:id", PageLive.Ecspanse.Battles.Lobby.JoinLive

    live "/ecspanse/battles/dump", PageLive.Ecspanse.Battles.Dump.IndexLive

    live "/ecspanse/battles/play",
         PageLive.Ecspanse.Battles.Play.IndexLive

    scope "/admin" do
      pipe_through :admin

      live "/", AdminLive.Index, :index
      live "/weapon_parameters", AdminLive.WeaponParameters
      live "/battle_room_parameters", AdminLive.BattleRoomParameters
      live "/profession_parameters", AdminLive.ProfessionParameters
      live "/professions", ProfessionLive.Index, :index
      live "/professions/new", ProfessionLive.Index, :new
      live "/professions/:id/edit", ProfessionLive.Index, :edit
      live "/professions/:id", ProfessionLive.Show, :show
      live "/professions/:id/show/edit", ProfessionLive.Show, :edit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", TarragonWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:tarragon, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard",
        metrics: TarragonWeb.Telemetry,
        additional_pages: []

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
