defmodule Cashier.Discounts.Discount do
  @moduledoc """
  Defines a Discount struct.
  """

  alias Cashier.Products
  alias Cashier.Products.Product

  defstruct [:code, :name, :type, :product_id, :buy, :get]

  @type code :: String.t()
  @type name :: String.t()
  @type type :: :fixed | :percentage
  @type product_id :: Product.code()

  @type t :: %__MODULE__{
          code: String.t(),
          name: String.t(),
          type: atom(),
          product_id: String.t(),
          buy: integer(),
          get: integer() | Decimal.t()
        }

  def validate(discount, params) do
    validate(Map.merge(discount, params))
  end

  def validate(%{code: code}) when not is_binary(code),
    do: {:error, :INVALID_CODE}

  def validate(%{name: name}) when not is_binary(name),
    do: {:error, :INVALID_NAME}

  def validate(%{buy: buy_qty}) when not is_integer(buy_qty),
    do: {:error, :INVALID_BUY_QTY}

  def validate(%{product_id: product_id, type: type, get: get} = params) do
    with {:product, true} <- valid_product(product_id),
         {:type, true} <- valid_type(type),
         true <- valid_get_value?(get) do
      get_value = (is_float(get) && Decimal.from_float(get)) || get

      {:ok,
       %__MODULE__{
         code: params.code,
         name: params.name,
         type: params.type,
         product_id: params.product_id,
         buy: params.buy,
         get: get_value
       }}
    else
      {:product, false} ->
        {:error, :INVALID_PRODUCT_ID}

      {:type, false} ->
        {:error, :INVALID_TYPE}

      false ->
        {:error, :INVALID_GET_VALUE}
    end
  end

  defp valid_product(product_id) do
    case Products.get_product(product_id) do
      {:ok, %Product{}} -> {:product, true}
      _any -> {:product, false}
    end
  end

  defp valid_type(type) when is_binary(type),
    do: valid_type(String.to_existing_atom(type))

  defp valid_type(type),
    do: {:type, type in [:fixed, :percentage]}

  defp valid_get_value?(get) do
    try do
      get = (is_float(get) && Decimal.from_float(get)) || Decimal.new(get)

      Decimal.compare(get, Decimal.new(0)) != :lt
    rescue
      _exception ->
        false
    end
  end
end
