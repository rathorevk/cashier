# Cashier

Cashier is an Elixir application for managing products, discounts, and carts in a cashier system. It allows for flexible rule-based discounts, and provides functionality to create, delete, and manage products and discounts, as well as adding and removing items from the cart.

## Features

- Create and delete products.
- Create and delete discounts.
- Add and remove items from the cart.
- Apply discounts and return the minimum expected price for the products in the cart.
- Flexible discount rules (fixed quantity, percentage-based, etc.).

## Getting Started

### 1. Prerequisites:

```bash
    elixir 1.15.7-otp-26
    erlang 26.2
```
* Elixir and Erlang versions are already added to `.tool-versions`.

### Installation

To use Cashier in your project, add it to your `mix.exs`:

```elixir
def deps do
  [
    {:cashier, "~> 0.1.0"}
  ]
end
```

### Start Server
To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Usage
### Creating Products
You can create a single product or multiple products at once.

```elixir
  # Create a single product
  {:ok, product} = Cashier.create_product(%{code: "GR1", name: "Green Tea", price: 3.11})

  # Create multiple products
  products = Cashier.create_products([
    %{code: "SR1", name: "Strawberries", price: 5.0},
    %{code: "CF1", name: "Coffee", price: 11.23}
  ])
```

### Creating Discounts
You can create a single discount or multiple discounts at once. Discounts can be of various types (e.g., fixed quantity, percentage-based).

```elixir
  # Create a single discount
  {:ok, discount} = Cashier.create_discount(%{code: "B1G1", name: "Buy One Get One", product_id: "GR1", type: :fixed, buy: 1, get: 1})

  # Create multiple discounts
  discounts = Cashier.create_discounts([
    %{code: "B3G10", name: "Buy Three Get 10% Off", product_id: "SR1", type: :percentage, buy: 3, get: 10},
    %{code: "B3G13", name: "Buy Three Get 1/3 Off", product_id: "CF1", type: :percentage, buy: 3, get: 33.33}
  ])
```

### Managing Carts
You can create a cart, add items to it, and remove items from it.

```elixir
# Add items to the cart
{:ok, %Cart{code: "CR1", products: ["GR1", "GR1", "SR1", "GR1", "CF1"], expected_price: Decimal.new("22.45")}} = 
  Cashier.add_to_cart(["GR1", "GR1", "SR1", "GR1", "CF1"]) # Adds the list of product to the cart

{:ok, %Cart{expected_price: Decimal.new("3.11")}} = Cashier.add_to_cart(["GR1", "GR1"])

# Add item to the existing cart
{:ok, %Cart{}} = Cashier.add_to_cart("CR1", "CF1") ## Add CF1 item to the CR1 cart 

# Remove items from the cart
{:ok, %Cart{}} = Cashier.remove_from_cart("CR1", "SR1") # Removes product SR1 from cart CR1
```

### ETS Tables
Cashier uses ETS tables to store products, discounts, and cart data. The ETS tables are named as follows:

```elixir
  :products - Stores product data.
  :discounts - Stores discount data.
  :carts - Stores cart data.
```

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
