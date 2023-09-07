defmodule StreamCoreWeb.Router do
  alias StreamCoreWeb.Auth

  use StreamCoreWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {StreamCoreWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", StreamCoreWeb do
    pipe_through(:browser)

    live_session(
      :no_authenticated_user,
      on_mount: {Auth.AuthLiveSession, :redirect_authenticated_user}
    ) do
      live("/login", UserLoginLive, :new)
      live("/register", UserLoginLive, :new)
    end

    post("/login", UserSessionController, :create)

    live_session(
      :default,
      on_mount: {Auth.AuthLiveSession, :mount_current_user}
    ) do
      live("/", HomeLive, :new)
      live("/:username", LiveStreamLive, :new)
    end
  end

  scope "/api", StreamCoreWeb do
    pipe_through(:api)

    get("/streams/:user_id/:filename", StreamController, :index)
    post("/users/login", UserSessionController, :create)
    delete("/users/logout", UserSessionController, :delete)
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:stream_core, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: StreamCoreWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
