defmodule BoutiqueInventory do
  def sort_by_price(inventory) do
    Enum.sort_by(inventory, &(&1.price))
  end

  def with_missing_price(inventory) do
    Enum.filter(inventory, &(&1.price == nil))
  end

  def update_names(inventory, old_word, new_word) do
    Enum.map(inventory, fn item ->
      Map.update!(item, :name, fn name ->
      String.replace(name, old_word, new_word)
      end)
    end)
  end

  def increase_quantity(item, count) do
    Map.update!(item, :quantity_by_size, fn quantity ->
      Enum.into(quantity, %{}, fn {k, v} -> {k, v + count} end)
      end)
  end

  def total_quantity(item) do
      Enum.reduce(item.quantity_by_size, 0, fn {key, _val}, acc -> acc + Map.get(item.quantity_by_size, key, 0) end)
  end
end
