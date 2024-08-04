defmodule Cashier.Carts.Cart do
  @moduledoc """
  Defines a Cart struct.
  """

  alias Cashier.Products

  defstruct [:code, :products, :expected_price]

  @type t :: %__MODULE__{
          code: String.t(),
          products: list(String.t()),
          expected_price: Decimal.t() | integer()
        }

  def validate(cart, params) do
    validate(Map.merge(cart, params))
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
