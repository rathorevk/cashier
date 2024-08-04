defmodule Cashier.Discounts.DiscountStore do
  @moduledoc """
  The `DiscountStore` module is your go-to place for managing all kinds of discounts.
  It's like our discount headquarters where we define and apply various discount rules to products.

  ## Features

  - **Adding Discounts**: Easily add new discounts with flexible rules.
  - **Applying Discounts**: Apply the right discount rules to products during checkout.
  - **Updating Discounts**: Modify existing discounts to keep up with new promotions.
  - **Deleting Discounts**: Remove outdated or expired discounts.

  ## Discount Rules

  The discount rules are stored in an ETS table and can be added or updated at runtime.
  Here are some examples of the types of discounts you can define:

  - **Buy One Get One Free**: Buy one product and get another one free.
  - **Bulk Discount**: Get a certain amount off when buying a specified quantity.
  - **Percentage Off**: Get a percentage off the price when buying a certain quantity.

  ## Note

  This module is designed to be flexible and extendable.
  You can define new types of discounts by simply adding new entries to the ETS table without changing the core code.
  """
  use GenServer

  alias Cashier.Discounts.Discount

  @table_name :discounts

  ## Public APIs
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def insert(%Discount{} = discount) do
    GenServer.call(__MODULE__, {:add_discount, discount})
  end

  def delete(%Discount{} = discount) do
    GenServer.call(__MODULE__, {:delete_discount, discount})
  end

  def get(id) do
    GenServer.call(__MODULE__, {:get_discount, id})
  end

  def delete_all do
    GenServer.call(__MODULE__, :delete_all_discounts)
  end

  def all do
    GenServer.call(__MODULE__, :get_all_discounts)
  end

  ## Callbacks

  @impl true
  def init(:ok) do
    :ets.new(@table_name, [:set, :public, :named_table])
    {:ok, %{}}
  end

  @impl true
  def handle_call({:add_discount, %Discount{} = discount}, _from, state) do
    %Discount{
      code: code,
      name: name,
      type: type,
      product_id: product_id,
      buy: buy_qty,
      get: get
    } = discount

    :ets.insert(@table_name, {code, name, type, product_id, buy_qty, get})
    {:reply, {:ok, discount}, state}
  end

  def handle_call({:delete_discount, discount}, _from, state) do
    true = :ets.delete(@table_name, discount.code)
    {:reply, :ok, state}
  end

  def handle_call({:get_discount, code}, _from, state) do
    discount = :ets.lookup(@table_name, code) |> format_discount()
    {:reply, discount, state}
  end

  def handle_call(:get_all_discounts, _from, state) do
    discounts = @table_name |> :ets.tab2list() |> format_discounts()
    {:reply, discounts, state}
  end

  def handle_call(:delete_all_discounts, _from, state) do
    true = @table_name |> :ets.delete_all_objects()
    {:reply, :ok, state}
  end

  defp format_discount([]), do: {:error, :NOT_FOUND}

  defp format_discount([{code, name, type, product_id, buy_qty, get}]) do
    {:ok,
     %Discount{
       code: code,
       name: name,
       type: type,
       product_id: product_id,
       buy: buy_qty,
       get: get
     }}
  end

  defp format_discounts(discounts) do
    Enum.map(discounts, fn {code, name, type, product_id, buy_qty, get} ->
      %Discount{
        code: code,
        name: name,
        type: type,
        product_id: product_id,
        buy: buy_qty,
        get: get
      }
    end)
  end
end
