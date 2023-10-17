defmodule BirdCount do
  def today([]), do: nil

  def today([head | _tail]), do: head

  def increment_day_count([]), do: [1]

  def increment_day_count([head | tail]), do: [head + 1 | tail]

  def has_day_without_birds?([]), do: false

  def has_day_without_birds?([0 | _tail]), do: true

  def has_day_without_birds?([_head | tail]), do: has_day_without_birds?(tail)

  def total(list), do: total(list, 0)

  defp total([], acc), do: acc

  defp total([head | tail], acc), do: total(tail, acc + head)

  def busy_days(list), do: busy_days(list, 0)

  defp busy_days([], acc), do: acc
  
  defp busy_days([head | tail], acc) when head >= 5, do: busy_days(tail, acc + 1)

  defp busy_days([_head | tail], acc), do: busy_days(tail, acc)
end
