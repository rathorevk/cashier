defmodule Cashier do
  @moduledoc """
  Cashier keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Cashier.Products
  alias Cashier.Discounts
  alias Cashier.Carts

  @doc """
  Creates a new product and inserts it into the ETS table.

  ## Parameters

    - `product`: A map representing the product.

  ## Returns

    - `{:ok, product}`: On success.
    - `{:error, INVALID_ARGS}`: on error.

  ## Examples

      iex> Cashier.create_product(%{code: "PR1", name: "Product 1", price: 11.0})
      :ok
  """
  defdelegate create_product(product), to: Products
  defdelegate create_products(products), to: Products

  @doc """
  Creates a new discount and inserts it into the ETS table.

  ## Parameters

    - `discount`: A map representing the discount.

  ## Returns

    - `{:ok, discount}`: On success.
    - `{:error, INVALID_ARGS}`: on error.

  ## Examples

      iex> Cashier.create_discount(%{code: "DC1", name: "Buy Two Get One", product_id: 1, type: :percentage, buy: 2, get: 1})
      :ok
  """
  defdelegate create_discount(discount), to: Discounts
  defdelegate create_discounts(discounts), to: Discounts

  @doc """
  Creates a new cart and inserts it into the ETS table.

  ## Parameters

    - `products`: The list of the product-ids.

  ## Returns

    - `{:ok, discount}`: On success.
    - `{:error, INVALID_ARGS}`: on error.

  ## Examples

      iex> Cashier.add_to_cart(["PR1", "PR2"])
      :ok
  """
  defdelegate add_to_cart(products), to: Carts, as: :create_cart

  def add_to_cart(cart_id, product_id) do
    Carts.update_cart(cart_id, product_id, :add)
  end

  @doc """
  Removes a product from the cart.

  ## Parameters

    - `cart_id`: The ID of the cart.
    - `product_id`: The ID of the product to remove.

  ## Returns

    - `{:ok, updated_cart}`: On success.
    - `{:error, INVALID_ARGS}`: on error.

  ## Examples

      iex> Cashier.remove_from_cart("CR1", "PR1")
      :ok
  """
  def remove_from_cart(cart_id, product_id) do
    Carts.update_cart(cart_id, product_id, :remove)
  end
end
