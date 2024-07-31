import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cashier, CashierWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "bt2pKY+8uUR6dQvEWXbm/qYTI85Zb2uqPxPlQK+62/pNxgOOFSJCAzok/9pqRYJ7",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
