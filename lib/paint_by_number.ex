defmodule PaintByNumber do
  def palette_bit_size(color_count) do
    palette_bit_size(1, color_count)
  end

  defp palette_bit_size(exp, color_count) do
    if Integer.pow(2, exp) < color_count, do: palette_bit_size(exp+1, color_count), else: exp
  end

  def empty_picture() do
    <<>>
  end

  def test_picture() do
    <<0::2, 1::2, 2::2, 3::2>>
  end

  def prepend_pixel(picture, color_count, pixel_color_index) do
    <<pixel_color_index::size(palette_bit_size(color_count)), picture::bitstring>>
  end

  def get_first_pixel(<<>>, _color_count) do
    nil
  end

  def get_first_pixel(picture, color_count) do
    size = palette_bit_size(color_count)
    <<value::size(size), _rest::bitstring>> = picture
    value
  end

  def drop_first_pixel(<<>>, _color_count) do
    <<>>
  end

  def drop_first_pixel(picture, color_count) do
    size = palette_bit_size(color_count)
    <<_value::size(size), rest::bitstring>> = picture
    rest
  end

  def concat_pictures(picture1, picture2) do
    <<picture1::bitstring, picture2::bitstring>>
  end
end
