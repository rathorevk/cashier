defmodule Cashier.Discounts do
  @moduledoc """
  The Discounts context.
  """

  alias Cashier.Discounts.Discount
  alias Cashier.Discounts.DiscountStore

  @doc """
  Returns the list of discounts.

  ## Examples

      iex> list_discounts()
      [%Discount{}, ...]

  """
  @spec list_discounts() :: [Discount.t()]
  def list_discounts do
    DiscountStore.all()
  end

  @doc """
  Gets a single discount.

  ## Examples

      iex> get_discount("GR1")
      {:ok, %Discount{}}

      iex> get_discount!("XY1")
      {:error, :not_found}

  """
  @spec get_discount(Discount.code()) :: {:ok, Discount.t()} | {:error, :NOT_FOUND}
  def get_discount(code), do: DiscountStore.get(code)

  @doc """
  Creates a discount.

  ## Examples

      iex> create_discount(%{field: value})
      {:ok, %Discount{}}

      iex> create_discount(%{field: bad_value})
      {:error, any()}

  """
  @spec create_discount(map()) :: {:ok, Discount.t()} | {:error, :DISCOUNT_EXISTS}
  def create_discount(attrs \\ %{}) do
    with {:ok, %Discount{} = discount} <- Discount.validate(attrs),
         {:error, :NOT_FOUND} <- get_discount(attrs.code),
         {:ok, %Discount{} = discount} <- DiscountStore.insert(discount) do
      {:ok, discount}
    else
      {:ok, %Discount{}} ->
        {:error, :DISCOUNT_EXISTS}

      {:error, _reason} = error ->
        error
    end
  end

  @spec create_discounts(map()) :: [Discount.t()]
  def create_discounts(attrs) do
    attrs
    |> Enum.map(&create_discount/1)
    |> Enum.reduce([], fn
      {:ok, value}, acc -> [value | acc]
      {:error, _}, acc -> acc
    end)
  end

  @doc """
  Updates a discount.

  ## Examples

      iex> update_discount(discount, %{field: new_value})
      {:ok, %Discount{}}

      iex> update_discount(discount, %{field: bad_value})
      {:error, any()}

  """
  @spec update_discount(Discount.t(), map()) :: {:ok, Discount.t()} | {:error, :NOT_FOUND}
  def update_discount(%Discount{code: code} = discount, attrs) do
    with {:ok, %Discount{} = discount} <- Discount.validate(discount, attrs),
         {:ok, %Discount{}} <- get_discount(code),
         {:ok, %Discount{} = discount} <- DiscountStore.insert(discount) do
      {:ok, discount}
    else
      {:error, _reason} = error ->
        error
    end
  end

  @doc """
  Deletes a discount.

  ## Examples

      iex> delete_discount(discount)
      {:ok, %Discount{}}

      iex> delete_discount(discount)
      {:error, any()}

  """
  @spec delete_discount(Discount.t()) :: :ok
  def delete_discount(%Discount{} = discount) do
    DiscountStore.delete(discount)
  end

  @doc """
  Delete all discounts.

  ## Examples

      iex> delete_discounts()
      :ok

  """
  @spec delete_all() :: :ok
  def delete_all do
    DiscountStore.delete_all()
  end
end
