defmodule Cashier.Products.Product do
  @moduledoc """
  Defines a Product struct.
  """

  defstruct [:code, :name, :price]

  @type t :: %__MODULE__{
          code: String.t(),
          name: String.t(),
          price: Decimal.t()
        }

  def validate(product, params) do
    validate(Map.merge(product, params))
  end

  def validate(%{code: code}) when not is_binary(code) do
    {:error, :INVALID_CODE}
  end

  def validate(%{name: name}) when not is_binary(name) do
    {:error, :INVALID_NAME}
  end

  def validate(%{code: code, name: name, price: price}) do
    case valid_price?(price) do
      false ->
        {:error, :INVALID_PRICE}

      true ->
        price = (is_float(price) && Decimal.from_float(price)) || Decimal.new(price)
        {:ok, %__MODULE__{code: code, name: name, price: Decimal.round(price, 2)}}
    end
  end

  def validate(_params) do
    {:error, :INVALID_ARGS}
  end

  defp valid_price?(price) do
    try do
      price = (is_float(price) && Decimal.from_float(price)) || Decimal.new(price)

      Decimal.compare(price, Decimal.new(0)) != :lt
    rescue
      _exception ->
        false
    end
  end
end
