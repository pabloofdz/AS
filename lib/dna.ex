defmodule DNA do
  def encode_nucleotide(?\s), do: 0b0000
  def encode_nucleotide(?A), do: 0b0001
  def encode_nucleotide(?C), do: 0b0010
  def encode_nucleotide(?G), do: 0b0100
  def encode_nucleotide(?T), do: 0b1000
  
  def decode_nucleotide(0b0000), do: ?\s
  def decode_nucleotide(0b0001), do: ?A
  def decode_nucleotide(0b0010), do: ?C
  def decode_nucleotide(0b0100), do: ?G
  def decode_nucleotide(0b1000), do: ?T

  def encode(dna), do: do_encode(dna, <<>>)
  defp do_encode([], acc), do: acc
  defp do_encode([nucleotide | rest], acc), do: do_encode(rest, <<acc::bitstring, encode_nucleotide(nucleotide)::4>>)

  def decode(dna), do: do_decode(dna, [])
  defp do_decode(<<>>, acc), do: reverse_list(acc)
  defp do_decode(<<nucleotide::4, rest::bitstring>>, acc), do: do_decode(rest, [decode_nucleotide(nucleotide) | acc])

  defp reverse_list(l), do: do_reverse_list(l, [])
  defp do_reverse_list([], acc), do: acc
  defp do_reverse_list([h | t], acc), do: do_reverse_list(t, [h | acc])

end
