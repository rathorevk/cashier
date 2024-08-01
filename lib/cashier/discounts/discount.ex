defmodule Cashier.Discounts.Discount do
  @moduledoc """
  Defines a Discount struct.
  """

  alias Cashier.Products
  alias Cashier.Products.Product

  defstruct [:code, :name, :type, :product_id, :threshold_qty, :value]

  @type t :: %__MODULE__{
          code: String.t(),
          name: String.t(),
          type: atom(),
          product_id: String.t(),
          threshold_qty: integer(),
          value: integer() | Decimal.t()
        }

  def validate(discount, params) do
    validate(Map.merge(discount, params))
  end

  def validate(%{code: code}) when not is_binary(code),
    do: {:error, :INVALID_CODE}

  def validate(%{name: name}) when not is_binary(name),
    do: {:error, :INVALID_NAME}

  def validate(%{threshold_qty: threshold_qty}) when not is_integer(threshold_qty),
    do: {:error, :INVALID_THRESHOLD_QTY}

  def validate(%{product_id: product_id, type: type, value: value} = params) do
    with {:product, true} <- valid_product(product_id),
         {:type, true} <- valid_type(type),
         true <- valid_value?(value) do
      {:ok,
       %__MODULE__{
         code: params.code,
         name: params.name,
         type: params.type,
         product_id: params.product_id,
         threshold_qty: params.threshold_qty,
         value: value
       }}
    else
      {:product, false} ->
        {:error, :INVALID_PRODUCT_ID}

      {:type, false} ->
        {:error, :INVALID_TYPE}

      false ->
        {:error, :INVALID_VALUE}
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

  defp valid_value?(price) do
    try do
      price = Decimal.new(price)
      Decimal.compare(price, Decimal.new(0)) != :lt
    rescue
      _exception ->
        false
    end
  end
end
