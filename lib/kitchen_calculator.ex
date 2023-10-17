defmodule KitchenCalculator do
  def get_volume(volume_pair) do
    elem(volume_pair, 1)
  end

  def to_milliliter({:milliliter, number}) do
    {:milliliter, number}
  end

  def to_milliliter({:cup, number}) do
    {:milliliter, number*240}
  end

  def to_milliliter({:fluid_ounce, number}) do
    {:milliliter, number*30}
  end

  def to_milliliter({:teaspoon, number}) do
    {:milliliter, number*5}
  end

  def to_milliliter({:tablespoon, number}) do
    {:milliliter, number*15}
  end

  def from_milliliter({:milliliter, number}, :milliliter) do
    {:milliliter, number}
  end

  def from_milliliter({:milliliter, number}, :cup) do
    {:cup, number/240}
  end

  def from_milliliter({:milliliter, number}, :fluid_ounce) do
    {:fluid_ounce, number/30}
  end

  def from_milliliter({:milliliter, number}, :teaspoon) do
    {:teaspoon, number/5}
  end

  def from_milliliter({:milliliter, number}, :tablespoon) do
    {:tablespoon, number/15}
  end

  def convert(volume_pair, unit) do
    from_milliliter(to_milliliter(volume_pair), unit)
  end
end
