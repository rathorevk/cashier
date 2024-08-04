defmodule Cashier.DiscountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Cashier.Discounts` context.
  """

  @doc """
  Generate a discount.
  """
  def discount_fixture(attrs \\ %{}) do
    {:ok, discount} =
      attrs
      |> Enum.into(%{
        code: "some code",
        name: "some name",
        type: :fixed,
        product_id: attrs[:product_id] || Cashier.ProductsFixtures.product_fixture().code,
        buy: 2,
        get: 1
      })
      |> Cashier.Discounts.create_discount()

    discount
  end
end
