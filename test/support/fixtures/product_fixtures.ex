defmodule Cashier.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Cashier.Products` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        code: "some code",
        name: "some name",
        price: "120.5"
      })
      |> Cashier.Products.create_product()

    product
  end
end
