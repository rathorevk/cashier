defmodule Cashier.Carts.Cart do
  @moduledoc """
  Defines a Cart struct.
  """

  alias Cashier.Products
  alias Cashier.Products.Product

  defstruct [:code, :products, :expected_price]

  @type code :: String.t()
  @type expected_price :: Decimal.t() | integer() | float()

  @type t :: %__MODULE__{
          code: code(),
          products: list(Product.code()),
          expected_price: expected_price()
        }

  def validate(%__MODULE__{products: products} = cart, product, :add = _ops) do
    validate(%{cart | products: products ++ [product]})
  end

  def validate(%__MODULE__{products: products} = cart, product, :remove = _ops) do
    validate(%{cart | products: products -- [product]})
  end

  def validate(%{code: code}) when not is_nil(code) and not is_binary(code) do
    {:error, :INVALID_CODE}
  end

  def validate(%{products: products} = attr) do
    case valid_products?(products) do
      true ->
        code = if is_struct(attr), do: attr.code, else: attr[:code]
        {:ok, %__MODULE__{code: code, products: products}}

      false ->
        {:error, :INVALID_PRODUCTS}
    end
  end

  def validate(_params) do
    {:error, :INVALID_ARGS}
  end

  defp valid_products?(products) when not is_list(products), do: false

  defp valid_products?(products) do
    Enum.all?(products, fn product_id ->
      product_id |> Products.get_product() |> elem(0) == :ok
    end)
  end
end
