defmodule CashierWeb.Router do
  use CashierWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CashierWeb do
    pipe_through :api
  end
end
