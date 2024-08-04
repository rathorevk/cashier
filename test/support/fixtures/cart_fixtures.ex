defmodule Cashier.CartsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Cashier.Carts` context.
  """

  @doc """
  Generate a cart.
  """
  def cart_fixture(attrs \\ %{}) do
    product = Cashier.ProductsFixtures.product_fixture()
    _discount = Cashier.DiscountsFixtures.discount_fixture(%{product_id: product.code})

    {:ok, cart} =
      attrs
      |> Enum.into(%{
        code: nil,
        products: [product.code, product.code],
        expected_price: nil
      })
      |> Cashier.Carts.create_cart()

    cart
  end
end
