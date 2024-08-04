defmodule Cashier.CartsTest do
  use ExUnit.Case

  alias Cashier.Carts
  alias Cashier.Carts.Cart
  alias Cashier.Discounts
  alias Cashier.Products

  import Cashier.CartsFixtures
  import Cashier.ProductsFixtures

  @invalid_attrs nil

  describe "carts" do
    setup do
      on_exit(fn ->
        Discounts.delete_all()
        Products.delete_all()
        Carts.delete_all()
      end)
    end

    test "list_carts/0 returns all carts" do
      cart = cart_fixture()
      assert Carts.list_carts() == [cart]
    end

    test "get_cart/1 returns the cart with given code" do
      cart = cart_fixture()
      assert Carts.get_cart(cart.code) == {:ok, cart}
    end

    test "create_cart/1 with valid data creates a cart" do
      product = product_fixture()
      valid_attrs = [product.code]

      assert {:ok, %Cart{} = cart} = Carts.create_cart(valid_attrs)

      assert cart.products == [product.code]
      assert cart.expected_price == product.price
    end

    test "create_cart/1 with invalid data returns error" do
      assert {:error, :INVALID_PRODUCTS} = Carts.create_cart(@invalid_attrs)
    end

    test "update_cart/2 with valid data updates the cart" do
      cart_fixture = cart_fixture()
      product = product_fixture(%{code: "UUS1"})

      assert {:ok, %Cart{} = cart} = Carts.update_cart(cart_fixture.code, product.code)
      assert cart.code == cart_fixture.code
      assert cart.products == cart_fixture.products ++ [product.code]
      assert cart.expected_price == Decimal.mult(product.price, 3)
    end

    test "update_cart/2 with invalid data returns error" do
      cart = cart_fixture()
      assert {:error, :INVALID_PRODUCTS} = Carts.update_cart(cart.code, nil)
      assert {:ok, cart} == Carts.get_cart(cart.code)
    end

    test "delete_cart/1 deletes the cart" do
      cart = cart_fixture()
      assert :ok == Carts.delete_cart(cart)
      assert {:error, :NOT_FOUND} == Carts.get_cart(cart.code)
    end
  end
end
