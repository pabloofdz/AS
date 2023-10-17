defmodule Username do
  def sanitize(username), do: sanitize(username, [])

  defp sanitize([], acc), do: acc
    
  defp sanitize([head | tail], acc) do
    sanitized =
      case head do
        head when head >= ?a and head <= ?z -> [head]
        ?_ -> ~c"_"
        ?ä -> ~c"ae"
        ?ö -> ~c"oe"
        ?ü -> ~c"ue"
        ?ß -> ~c"ss"
        _ -> ~c""
      end
    sanitize(tail, acc ++ sanitized)
  end
end
