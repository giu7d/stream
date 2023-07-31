defmodule StreamCore.Validator do
  def cast(params, schema) do
    with {:ok, params} <- Tarams.cast(params, schema) do
      {:ok, Tarams.clean_nil(params)}
    end
  end
end
