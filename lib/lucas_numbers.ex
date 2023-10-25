defmodule LucasNumbers do
  @moduledoc """
  Lucas numbers are an infinite sequence of numbers which build progressively
  which hold a strong correlation to the golden ratio (φ or ϕ)

  E.g.: 2, 1, 3, 4, 7, 11, 18, 29, ...
  """
  def generate(1), do: [2]
  def generate(2), do: [2,1]
  def generate(count) when is_integer(count) and count > 2 do
    t =
      {2, 1}
      |> Stream.iterate(fn {l, r} -> {r, l + r} end) 
      |> Stream.map(fn {_, r} -> r end)  
      |> Enum.take(count - 1) 
    [2 | t]
  end
  def generate(_), do: raise(ArgumentError, "count must be specified as an integer >= 1") 
end
