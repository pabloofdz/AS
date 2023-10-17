defmodule Lasagna do
  def expected_minutes_in_oven do
    40
  end

  def remaining_minutes_in_oven(x) do
    expected_minutes_in_oven() - x
  end

  def preparation_time_in_minutes(x) do
    x*2
  end

  def total_time_in_minutes(x, y) do
    preparation_time_in_minutes(x) + y
  end

  def alarm do
    "Ding!"
  end
end
