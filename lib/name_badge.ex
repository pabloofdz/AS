defmodule NameBadge do
  def print(id, name, department) do
    department = if department, do: String.upcase(department), else: "OWNER"
    if id, do: "[#{id}] - #{name} - #{department}", else: "#{name} - #{department}"
  end
end
