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
  def get_product(id), do: ProductStore.get(id)

  @doc """
  Gets the list of products by ids.

  ## Examples

      iex> get_products(ids)
      [%Product{}, ...]

  """
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

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, any()}

  """
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
  def delete_product(%Product{} = product) do
    ProductStore.delete(product)
  end

  @doc """
  Delete all products.

  ## Examples

      iex> delete_products()
      :ok

  """
  def delete_all do
    ProductStore.delete_all()
  end
end
