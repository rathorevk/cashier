defmodule Cashier.DiscountsTest do
  use ExUnit.Case

  alias Cashier.Discounts
  alias Cashier.Discounts.Discount
  alias Cashier.Products

  import Cashier.DiscountsFixtures
  import Cashier.ProductsFixtures

  @invalid_attrs %{
    code: nil,
    name: nil,
    type: nil,
    product_id: nil,
    buy: nil,
    get: nil
  }

  describe "discounts" do
    setup do
      on_exit(fn ->
        Discounts.delete_all()
        Products.delete_all()
      end)
    end

    test "list_discounts/0 returns all discounts" do
      discount = discount_fixture()
      assert Discounts.list_discounts() == [discount]
    end

    test "get_discount/1 returns the discount with given code" do
      discount = discount_fixture()
      assert Discounts.get_discount(discount.code) == {:ok, discount}
    end

    test "create_discount/1 with valid data creates a discount" do
      product = product_fixture()

      valid_attrs = %{
        code: "some new code",
        name: "some new name",
        type: "percentage",
        product_id: product.code,
        buy: 5,
        get: 10
      }

      assert {:ok, %Discount{} = discount} = Discounts.create_discount(valid_attrs)
      assert discount.code == "some new code"
      assert discount.name == "some new name"
      assert discount.type == "percentage"
      assert discount.product_id == product.code
      assert discount.buy == 5
      assert discount.get == 10
    end

    test "create_discount/1 with invalid data returns error" do
      attrs_invalid_code = %{
        code: nil,
        name: "some name",
        type: "some type",
        product_id: "GR1",
        buy: 2,
        get: 1
      }

      assert {:error, :INVALID_CODE} = Discounts.create_discount(attrs_invalid_code)

      attrs_invalid_product = %{
        code: "some code",
        name: "some name",
        type: "some type",
        product_id: nil,
        buy: 2,
        get: 1
      }

      assert {:error, :INVALID_PRODUCT_ID} = Discounts.create_discount(attrs_invalid_product)

      attrs_invalid_qty = %{
        code: "some code",
        name: "some name",
        type: "some type",
        product_id: "GR1",
        buy: nil,
        get: 1
      }

      assert {:error, :INVALID_BUY_QTY} = Discounts.create_discount(attrs_invalid_qty)
    end

    test "update_discount/2 with valid data updates the discount" do
      discount = discount_fixture()
      product = product_fixture(code: "GR-U")

      update_attrs = %{
        name: "some updated name",
        type: "percentage",
        product_id: product.code,
        get: 50
      }

      assert {:ok, %Discount{} = discount} = Discounts.update_discount(discount, update_attrs)
      assert discount.name == "some updated name"
      assert discount.type == "percentage"
      assert discount.product_id == product.code
      assert discount.buy == 2
      assert discount.get == 50
    end

    test "update_discount/2 with invalid data returns error" do
      discount = discount_fixture()
      assert {:error, :INVALID_CODE} = Discounts.update_discount(discount, @invalid_attrs)
      assert {:ok, discount} == Discounts.get_discount(discount.code)
    end

    test "delete_discount/1 deletes the discount" do
      discount = discount_fixture()
      assert :ok == Discounts.delete_discount(discount)
      assert {:error, :NOT_FOUND} == Discounts.get_discount(discount.code)
    end
  end
end
