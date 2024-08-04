defmodule Cashier.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: Cashier.PubSub},
      # Start a worker by calling: Cashier.Worker.start_link(arg)
      # {Cashier.Worker, arg},
      {Cashier.Products.ProductStore, []},
      {Cashier.Discounts.DiscountStore, []},
      {Cashier.Carts.CartStore, []},
      # Start to serve requests, typically the last entry
      CashierWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cashier.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CashierWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
