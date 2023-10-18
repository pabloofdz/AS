defmodule TopSecret do
  def to_ast(string) do
    Code.string_to_quoted!(string)
  end

  def decode_secret_message_part({op, _, argument_list} = ast, acc) when op in [:def, :defp] do 
    {name, args} = get_name_and_args(argument_list)
    arity = length(args)
    message = String.slice(to_string(name), 0, arity)
    {ast, [message | acc]}
  end

  def decode_secret_message_part(ast, acc) do        
    {ast, acc}
  end          

  defp get_name_and_args([{:when, _, args} | _]), do: get_name_and_args(args)

  defp get_name_and_args([{name, _, args} | _]) when is_list(args), do: {name, args}

  defp get_name_and_args([{name, _, args} | _]) when is_atom(args), do: {name, []}

  def decode_secret_message(string) do
    {_, acc} = Macro.prewalk(to_ast(string), [], &decode_secret_message_part/2)
    Enum.reverse(acc)
    |> Enum.join("")
  end
end
