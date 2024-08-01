defmodule Cashier.ProductsTest do
  use ExUnit.Case, async: true

  alias Cashier.Products
  alias Cashier.Products.Product

  import Cashier.ProductsFixtures

  @invalid_attrs %{code: nil, name: nil, price: nil}

  describe "products" do
    setup do
      on_exit(fn -> Products.delete_all() end)
    end

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Products.list_products() == [product]
    end

    test "get_product/1 returns the product with given code" do
      product = product_fixture()
      assert Products.get_product(product.code) == {:ok, product}
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{code: "some code", name: "some name", price: "120.5"}

      assert {:ok, %Product{} = product} = Products.create_product(valid_attrs)
      assert product.code == "some code"
      assert product.name == "some name"
      assert product.price == "120.5"
    end

    test "create_product/1 with invalid data returns error" do
      attrs_invalid_code = %{code: nil, name: "some name", price: 112}
      assert {:error, :INVALID_CODE} = Products.create_product(attrs_invalid_code)

      attrs_invalid_name = %{code: "some code", name: nil, price: 112}
      assert {:error, :INVALID_NAME} = Products.create_product(attrs_invalid_name)

      attrs_invalid_price = %{code: "some code", name: "some name", price: nil}
      assert {:error, :INVALID_PRICE} = Products.create_product(attrs_invalid_price)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      update_attrs = %{code: "some updated code", name: "some updated name", price: "456.7"}

      assert {:ok, %Product{} = product} = Products.update_product(product, update_attrs)
      assert product.code == "some updated code"
      assert product.name == "some updated name"
      assert product.price == "456.7"
    end

    test "update_product/2 with invalid data returns error" do
      product = product_fixture()
      assert {:error, :INVALID_CODE} = Products.update_product(product, @invalid_attrs)
      assert {:ok, product} == Products.get_product(product.code)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert :ok == Products.delete_product(product)
      assert {:error, :NOT_FOUND} == Products.get_product(product.code)
    end
  end
end