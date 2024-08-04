defmodule Cashier.Carts.CartStore do
  @moduledoc """
    The `CartStore` module handles all your shopping cart needs.
    It's the place where products are added, removed, and totals are calculated.

    ## Features

    - **Adding Items**: Add products to your cart easily.
    - **Removing Items**: Remove products from your cart if you change your mind.
    - **Calculating Totals**: Get the total cost of the items in your cart, including any discounts.

    ## Notes

    - This module uses ETS to store cart data in memory, ensuring fast access and updates.
    - All prices are handled using the `Decimal` library to maintain precision, especially for currency calculations.
    - Discounts are applied automatically when calculating totals, using the rules defined in the `DiscountStore`.

    ## Internals

    - **ETS Tables**: The cart data is stored in ETS tables, which are fast and efficient for in-memory operations.
    - **Data Structures**: Each cart is a collection of cart-ID(code), item IDs, and price.
    - **Discount Integration**: Automatically integrates with `DiscountStore` to apply any relevant discounts during total calculation.
  """
  use GenServer

  alias Cashier.Carts.Cart

  @table_name :carts

  ## Public APIs
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def insert(%Cart{} = cart) do
    GenServer.call(__MODULE__, {:add_cart, cart})
  end

  def get(code) do
    GenServer.call(__MODULE__, {:get_cart, code})
  end

  def delete(%Cart{} = cart) do
    GenServer.call(__MODULE__, {:delete_cart, cart})
  end

  def all do
    GenServer.call(__MODULE__, :get_all_carts)
  end

  def delete_all do
    GenServer.call(__MODULE__, :delete_all_carts)
  end

  ## Callbacks

  @impl true
  def init(:ok) do
    :ets.new(@table_name, [:set, :public, :named_table])
    {:ok, %{counter: 0}}
  end

  @impl true
  def handle_call({:add_cart, %Cart{} = cart}, _from, state) do
    %Cart{code: code, products: products, expected_price: expected_price} = cart
    code = code || generate_code(state.counter)

    cart = %Cart{code: code, products: products, expected_price: expected_price}
    :ets.insert(@table_name, {code, products, expected_price})
    {:reply, {:ok, cart}, %{state | counter: state.counter + 1}}
  end

  def handle_call({:delete_cart, cart}, _from, state) do
    true = :ets.delete(@table_name, cart.code)
    {:reply, :ok, state}
  end

  def handle_call({:get_cart, code}, _from, state) do
    cart = :ets.lookup(@table_name, code) |> format_cart()
    {:reply, cart, state}
  end

  def handle_call(:get_all_carts, _from, state) do
    carts = @table_name |> :ets.tab2list() |> format_carts()
    {:reply, carts, state}
  end

  def handle_call(:delete_all_carts, _from, state) do
    true = @table_name |> :ets.delete_all_objects()
    {:reply, :ok, state}
  end

  defp format_cart([]), do: {:error, :NOT_FOUND}

  defp format_cart([{code, products, expected_price}]) do
    {:ok, %Cart{code: code, products: products, expected_price: expected_price}}
  end

  defp format_carts(carts) do
    Enum.map(carts, fn {code, products, expected_price} ->
      %Cart{code: code, products: products, expected_price: expected_price}
    end)
  end

  defp generate_code(counter) do
    "CR#{counter}"
  end
end
