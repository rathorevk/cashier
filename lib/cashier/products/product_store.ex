defmodule Cashier.Products.ProductStore do
  @moduledoc """
  The `ProductStore` module is all about managing our awesome product catalog.
  Think of it as our little warehouse in code form.

  ## Features

  - **Adding Products**: Easily add new products to our store.
  - **Fetching Products**: Look up products by their Code to see what we have in stock.
  - **Updating Products**: Change product details whenever needed.
  - **Deleting Products**: Remove products that are no longer available.

  ## Note

  This module doesn't use a database like Ecto; instead, it keeps everything in memory using ETS. It's fast and simple for our needs.
  """
  use GenServer

  alias Cashier.Products.Product

  @table_name :products

  ## Public APIs
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def insert(%Product{} = product) do
    GenServer.call(__MODULE__, {:add_product, product})
  end

  def get(code) do
    GenServer.call(__MODULE__, {:get_product, code})
  end

  def delete(%Product{} = product) do
    GenServer.call(__MODULE__, {:delete_product, product})
  end

  def all do
    GenServer.call(__MODULE__, :get_all_products)
  end

  def delete_all do
    GenServer.call(__MODULE__, :delete_all_products)
  end

  ## Callbacks

  @impl true
  def init(:ok) do
    :ets.new(@table_name, [:set, :public, :named_table])
    {:ok, %{}}
  end

  @impl true
  def handle_call({:add_product, %Product{} = product}, _from, state) do
    %Product{code: code, name: name, price: price} = product
    :ets.insert(@table_name, {code, name, price})
    {:reply, {:ok, product}, state}
  end

  def handle_call({:delete_product, product}, _from, state) do
    true = :ets.delete(@table_name, product.code)
    {:reply, :ok, state}
  end

  def handle_call({:get_product, code}, _from, state) do
    product = :ets.lookup(@table_name, code) |> format_product()
    {:reply, product, state}
  end

  def handle_call(:get_all_products, _from, state) do
    products = @table_name |> :ets.tab2list() |> format_products()
    {:reply, products, state}
  end

  def handle_call(:delete_all_products, _from, state) do
    true = @table_name |> :ets.delete_all_objects()
    {:reply, :ok, state}
  end

  defp format_product([]), do: {:error, :NOT_FOUND}

  defp format_product([{code, name, price}]) do
    {:ok, %Product{code: code, name: name, price: price}}
  end

  defp format_products(products) do
    Enum.map(products, fn {code, name, price} ->
      %Product{code: code, name: name, price: price}
    end)
  end
end
