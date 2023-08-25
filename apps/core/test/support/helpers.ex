defmodule StreamCore.Helpers do
  def equals(result, expected) do
    result == expected
  end

  def different(result, expected) do
    result != expected
  end
end
