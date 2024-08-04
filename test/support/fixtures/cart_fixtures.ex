defmodule Cashier.CartsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Cashier.Carts` context.
  """

  @doc """
  Generate a cart.
  """
  def cart_fixture() do
    product = Cashier.ProductsFixtures.product_fixture()
    _discount = Cashier.DiscountsFixtures.discount_fixture(%{product_id: product.code})

    {:ok, cart} = Cashier.Carts.create_cart([product.code, product.code])

    cart
  end
end
