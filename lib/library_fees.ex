defmodule LibraryFees do
  def datetime_from_string(string) do
    NaiveDateTime.from_iso8601!(string)
  end

  def before_noon?(datetime) do
    Time.compare(~T[12:00:00], NaiveDateTime.to_time(datetime)) == :gt
  end

  def return_date(checkout_datetime) do
    days = if before_noon?(checkout_datetime), do: 28, else: 29
    NaiveDateTime.add(checkout_datetime, days * 24 * 60 * 60)
    |> NaiveDateTime.to_date()
  end

  def days_late(planned_return_date, actual_return_datetime) do
    Date.diff(NaiveDateTime.to_date(actual_return_datetime), planned_return_date)
    |> max(0)
  end

  def monday?(datetime) do
    NaiveDateTime.to_date(datetime)
    |> Date.day_of_week() == 1
  end

  def calculate_late_fee(checkout, return, rate) do
    return_datetime = datetime_from_string(return)
    days_late = days_late(return_date(datetime_from_string(checkout)), return_datetime)
    fee = rate * days_late
    if monday?(return_datetime), do: div(fee, 2), else: fee
  end
end
