defmodule Cashier.Carts do
  @moduledoc """
  The Carts context.
  """

  alias Cashier.Carts.Cart
  alias Cashier.Carts.CartStore
  alias Cashier.Discounts
  alias Cashier.Discounts.Discount
  alias Cashier.Products
  alias Cashier.Products.Product

  @doc """
  Returns the list of carts.

  ## Examples

      iex> list_carts()
      [%Cart{}, ...]

  """
  def list_carts do
    CartStore.all()
  end

  @doc """
  Gets a single cart.

  ## Examples

      iex> get_cart("CR1")
      {:ok, %Cart{}}

      iex> get_cart("XY1")
      {:error, :NOT_FOUND}

  """
  def get_cart(id), do: CartStore.get(id)

  @doc """
  Creates a cart.

  ## Examples

      iex> create_cart(%{field: value})
      {:ok, %Cart{}}

      iex> create_cart(%{field: bad_value})
      {:error, any()}

  """
  def create_cart(attrs \\ %{}) do
    with {:ok, %Cart{} = cart} <- Cart.validate(attrs),
         {:error, :NOT_FOUND} <- get_cart(cart.code),
         cart = apply_discounts(cart),
         {:ok, %Cart{} = cart} <- CartStore.insert(cart) do
      {:ok, cart}
    else
      {:ok, %Cart{}} ->
        {:error, :PRODUCT_EXISTS}

      {:error, _reason} = error ->
        error
    end
  end

  @doc """
  Updates a cart.

  ## Examples

      iex> update_cart(cart, %{field: new_value})
      {:ok, %Cart{}}

      iex> update_cart(cart, %{field: bad_value})
      {:error, any()}

  """
  def update_cart(%Cart{code: code} = cart, attrs) do
    with {:ok, %Cart{} = cart} <- Cart.validate(cart, attrs),
         {:ok, %Cart{}} <- get_cart(code),
         %Cart{} = updated_cart <- apply_discounts(cart),
         {:ok, %Cart{} = cart} <- CartStore.insert(updated_cart) do
      {:ok, cart}
    else
      {:error, _reason} = error ->
        error
    end
  end

  @doc """
  Deletes a cart.

  ## Examples

      iex> delete_cart(cart)
      {:ok, %Cart{}}

      iex> delete_cart(cart)
      {:error, any()}

  """
  def delete_cart(%Cart{} = cart) do
    CartStore.delete(cart)
  end

  @doc """
  Delete all carts.

  ## Examples

      iex> delete_carts()
      :ok

  """
  def delete_all do
    CartStore.delete_all()
  end

  defguardp eligible_for_discount?(product_id, quantity, discount_p_id, discount_qty)
            when product_id == discount_p_id and quantity >= discount_qty

  ## Discount calculations
  defp apply_discounts(%Cart{products: product_ids} = cart) do
    products_map = Enum.frequencies(product_ids)
    products = products_map |> Map.keys() |> Products.get_products()

    discounts = Discounts.list_discounts()

    total_expected_price = do_apply_discount(products, products_map, discounts, Decimal.new("0"))

    %{cart | expected_price: total_expected_price}
  end

  defp do_apply_discount([], _products_map, _discounts, total_expected_price),
    do: total_expected_price

  defp do_apply_discount([%Product{code: code} = p | rest], products_map, discounts, total_price) do
    product_qty = products_map[code]

    total_product_price =
      Enum.reduce(discounts, Decimal.mult(p.price, product_qty), fn %Discount{} = d, acc ->
        # Update totel product price after discount
        exp_price = do_apply(d, p, product_qty)
        Decimal.min(acc, exp_price)
      end)

    updated_total_price = Decimal.add(total_price, total_product_price)
    do_apply_discount(rest, products_map, discounts, updated_total_price)
  end

  defp do_apply(
         %Discount{type: :fixed, product_id: d_product_id, threshold_qty: buy_qty} = d,
         %Product{code: code, price: price},
         product_qty
       )
       when eligible_for_discount?(code, product_qty, d_product_id, buy_qty) do
    get_qty = d.value
    # Calculate the number of sets that qualify for the discount
    sets = div(product_qty, buy_qty + get_qty)
    # Calculate the remaining items that do not qualify for a full set discount
    remaining_items = rem(product_qty, buy_qty + get_qty)

    # Calculate the total quantity to be paid for
    paid_quantity = sets * buy_qty + remaining_items

    # final amount
    Decimal.mult(price, paid_quantity)
  end

  defp do_apply(%Discount{type: :fixed}, %Product{price: price}, product_qty),
    do: Decimal.mult(price, product_qty)

  defp do_apply(
         %Discount{type: :percentage, product_id: d_product_id, threshold_qty: buy_qty} = d,
         %Product{code: code, price: price},
         product_qty
       )
       when eligible_for_discount?(code, product_qty, d_product_id, buy_qty) do
    discount_off = d.value
    # Calculate the total amount before discount
    total_price = Decimal.mult(price, product_qty)

    # Calculate the discount amount
    discount = total_price |> Decimal.mult(discount_off) |> Decimal.div(100)

    # final amount
    Decimal.sub(total_price, discount)
  end

  defp do_apply(%Discount{type: :percentage}, %Product{price: price}, product_qty),
    do: Decimal.mult(price, product_qty)
end
