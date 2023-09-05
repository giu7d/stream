defmodule StreamCore.Helpers do
  def equals(result, expected) do
    result == expected
  end

  def different(result, expected) do
    result != expected
  end

  def match_json(json, expected) do
    json
    |> Jason.decode!()
    |> keys_to_atoms()
    |> Map.equal?(expected)
  end

  defp keys_to_atoms(string_key_map) do
    for {key, val} <- string_key_map, into: %{}, do: {String.to_atom(key), val}
  end
end
