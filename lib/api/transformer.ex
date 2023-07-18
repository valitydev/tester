defprotocol Tester.Api.Transformer do
  @spec transform(t, any) :: any()
  def transform(type, value)
end

defimpl Tester.Api.Transformer, for: Any do
  @spec transform(struct, any) :: any()
  def transform(type, value) do
    Poison.Decode.transform(value, %{as: type})
  end
end

defimpl Tester.Api.Transformer, for: List do
  @spec transform([struct], [any]) :: any()
  def transform([type], values) when is_list(values) do
    for value <- values, do: Poison.Decode.transform(value, %{as: type})
  end
end

defmodule Tester.Api.Transform do
  @spec transform_with_fields(struct, map(), Keyword.t()) :: any()
  def transform_with_fields(type, value, fields) do
    transformed = Poison.Decode.transform(value, %{as: type})

    Enum.reduce(fields, transformed, fn {key, as}, acc ->
      case Map.fetch(acc, key) do
        {:ok, value} ->
          Map.put(acc, key, Poison.Decode.transform(value, %{as: as}))

        :error ->
          acc
      end
    end)
  end
end
