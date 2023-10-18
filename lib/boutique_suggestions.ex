defmodule BoutiqueSuggestions do
  def get_combinations(tops, bottoms, options \\ [maximum_price: 100]) do
    for top <- tops,
      bottom <- bottoms,
      top.base_color != bottom.base_color and
      options[:maximum_price] != nil and
      top.price + bottom.price <= options[:maximum_price] do
      {top, bottom}
    end
  end
end
