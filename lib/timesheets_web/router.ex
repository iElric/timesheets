defmodule TimesheetsWeb.Router do
  use TimesheetsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug TimesheetsWeb.Plugs.FetchCurrentUser
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TimesheetsWeb do
    pipe_through :browser

    get "/", PageController, :index
    post "/sheet/approve", SheetController, :approve
    post "/sheet/subtract", SheetController, :subtract
    post "/sheets/new", SheetController, :new
    get "/sheets/new", SheetController, :new
    resources "/users", UserController,
    only: [:show]
    resources "/sessions", SessionController,
    only: [:new, :create, :delete], singleton: true
    resources "/sheets", SheetController,
    only: [:create, :index]
    #resources "/jobs", JobController
    resources "/tasks", TaskController,
    only: [:create, :index]
  end

  # Other scopes may use custom stacks.
  # scope "/api", TimesheetsWeb do
  #   pipe_through :api
  # end
end
