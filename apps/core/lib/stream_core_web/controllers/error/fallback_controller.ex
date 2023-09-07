defmodule StreamCoreWeb.FallbackController do
  alias StreamCoreWeb.Validator

  use StreamCoreWeb, :controller

  def call(conn, {:error, :unauthorized}) do
    conn
    |> gen_error_response(
      :unauthorized,
      "This user does not have correct email and/or password.",
      ~p"/login"
    )
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> gen_error_response(
      :not_found,
      "Not able to found requested data.",
      ~p"/"
    )
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> gen_error_response(
      :bad_request,
      "Bad request format.",
      ~p"/"
    )
  end

  def call(conn, _) do
    conn
    |> gen_error_response(
      500,
      "Internal server error.",
      ~p"/"
    )
  end

  defp gen_error_response(conn, status, message, redirect) do
    if Validator.is_api_scope?(conn) do
      conn
      |> send_resp(status, message)
    else
      conn
      |> put_flash(status, message)
      |> redirect(to: redirect)
    end
  end
end
