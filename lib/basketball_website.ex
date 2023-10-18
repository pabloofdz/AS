defmodule BasketballWebsite do
  def extract_from_path(data, path) do
    extract_from_path_aux(data, String.split(path, "."))
  end

  defp extract_from_path_aux(nil, _), do: nil

  defp extract_from_path_aux(data, []), do: data

  defp extract_from_path_aux(data, [h|t]), do: extract_from_path_aux(data[h], t)

  def get_in_path(data, path) do
    get_in(data, String.split(path, "."))
  end
end
