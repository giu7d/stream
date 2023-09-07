defmodule StreamCoreWeb.Validator do
  def cast(params, schema) do
    with {:ok, params} <- Tarams.cast(params, schema) do
      {:ok, Tarams.clean_nil(params)}
    else
      _ -> {:error, :bad_request}
    end
  end

  def is_api_scope?(%Plug.Conn{request_path: request_path}) do
    String.contains?(request_path, "/api")
  end
end
