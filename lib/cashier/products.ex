defmodule Cashier.Products do
  @moduledoc """
  The Products context.
  """

  alias Cashier.Products.Product
  alias Cashier.Products.ProductStore

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  @spec list_products() :: [Product.t()]
  def list_products do
    ProductStore.all()
  end

  @doc """
  Gets a single product.

  ## Examples

      iex> get_product("GR1")
      {:ok, %Product{}}

      iex> get_product("XY1")
      {:error, :NOT_FOUND}

  """
  @spec get_product(Product.code()) :: {:ok, Product.t()} | {:error, :NOT_FOUND}
  def get_product(id), do: ProductStore.get(id)

  @doc """
  Gets the list of products by ids.

  ## Examples

      iex> get_products(ids)
      [%Product{}, ...]

  """
  @spec get_products([Product.code()]) :: [Product.t()]
  def get_products(ids) do
    ProductStore.get_products(ids)
  end

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, any()}

  """
  @spec create_product(map()) :: {:ok, Product.t()} | {:error, :PRODUCT_EXISTS}
  def create_product(attrs \\ %{}) do
    with {:ok, %Product{} = product} <- Product.validate(attrs),
         {:error, :NOT_FOUND} <- get_product(attrs.code),
         {:ok, %Product{} = product} <- ProductStore.insert(product) do
      {:ok, product}
    else
      {:ok, %Product{}} ->
        {:error, :PRODUCT_EXISTS}

      {:error, _reason} = error ->
        error
    end
  end

  @spec create_products(map()) :: [Product.t()]
  def create_products(attrs) do
    attrs
    |> Enum.map(&create_product/1)
    |> Enum.reduce([], fn
      {:ok, value}, acc -> [value | acc]
      {:error, _}, acc -> acc
    end)
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, any()}

  """
  @spec update_product(Product.t(), map()) :: {:ok, Product.t()} | {:error, :NOT_FOUND}
  def update_product(%Product{code: code} = product, attrs) do
    with {:ok, %Product{} = product} <- Product.validate(product, attrs),
         {:ok, %Product{}} <- get_product(code),
         {:ok, %Product{} = product} <- ProductStore.insert(product) do
      {:ok, product}
    else
      {:error, _reason} = error ->
        error
    end
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, any()}

  """
  @spec delete_product(Product.t()) :: :ok
  def delete_product(%Product{} = product) do
    ProductStore.delete(product)
  end

  @doc """
  Delete all products.

  ## Examples

      iex> delete_products()
      :ok

  """
  @spec delete_all() :: :ok
  def delete_all do
    ProductStore.delete_all()
  end
end
