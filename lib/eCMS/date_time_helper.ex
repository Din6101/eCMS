defmodule ECMS.DateTimeHelper do
  @moduledoc """
  Helper functions for working with Malaysia timezone (UTC+8)
  Malaysia is always UTC+8 (no daylight saving time)
  """

  @malaysia_offset_seconds 8 * 3600  # UTC+8 in seconds (8 hours * 3600 seconds)

  @doc """
  Get current datetime in Malaysia timezone (UTC+8)
  Returns a NaiveDateTime with time adjusted for +8 hours
  """
  def now_malaysia do
    DateTime.utc_now()
    |> DateTime.add(@malaysia_offset_seconds, :second)
    |> DateTime.to_naive()
  end

  @doc """
  Get current date in Malaysia timezone
  """
  def today_malaysia do
    malaysia_now = DateTime.utc_now()
    |> DateTime.add(@malaysia_offset_seconds, :second)
    |> DateTime.to_naive()

    NaiveDateTime.to_date(malaysia_now)
  end

  @doc """
  Convert UTC datetime to Malaysia timezone (UTC+8)
  Simply adds 8 hours to the UTC time and returns as NaiveDateTime for display
  """
  def to_malaysia_time(utc_datetime) when is_struct(utc_datetime, DateTime) do
    # Ensure it's in UTC
    utc = if utc_datetime.time_zone == "Etc/UTC" do
      utc_datetime
    else
      DateTime.shift_zone!(utc_datetime, "Etc/UTC")
    end
    # Add 8 hours and convert to NaiveDateTime for display
    utc
    |> DateTime.add(@malaysia_offset_seconds, :second)
    |> DateTime.to_naive()
  end

  def to_malaysia_time(naive_datetime) when is_struct(naive_datetime, NaiveDateTime) do
    naive_datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.add(@malaysia_offset_seconds, :second)
    |> DateTime.to_naive()
  end

  @doc """
  Get start of day in Malaysia timezone for a given date
  Returns UTC datetime that represents 00:00:00 Malaysia time
  """
  def start_of_day_malaysia(date \\ today_malaysia()) do
    # Create datetime at start of day (00:00:00) in Malaysia timezone
    # This is 16:00:00 previous day in UTC (subtract 8 hours)
    {:ok, naive_dt} = NaiveDateTime.new(date, ~T[00:00:00])
    naive_dt
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.add(-@malaysia_offset_seconds, :second)
  end

  @doc """
  Get end of day in Malaysia timezone for a given date
  Returns UTC datetime that represents 23:59:59 Malaysia time
  """
  def end_of_day_malaysia(date \\ today_malaysia()) do
    # Create datetime at end of day (23:59:59) in Malaysia timezone
    # This is 15:59:59 same day in UTC (subtract 8 hours)
    {:ok, naive_dt} = NaiveDateTime.new(date, ~T[23:59:59])
    naive_dt
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.add(-@malaysia_offset_seconds, :second)
  end

  @doc """
  Format datetime to Malaysia timezone string
  """
  def format_malaysia_time(datetime) when is_struct(datetime, DateTime) do
    datetime
    |> to_malaysia_time()
    |> NaiveDateTime.to_string()
  end

  def format_malaysia_time(naive_datetime) when is_struct(naive_datetime, NaiveDateTime) do
    naive_datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> to_malaysia_time()
    |> NaiveDateTime.to_string()
  end

  @doc """
  Format datetime to separate date and time in 12-hour format
  Returns a map with :date and :time keys
  """
  def format_date_time_12h(datetime) when is_struct(datetime, DateTime) do
    malaysia_time = to_malaysia_time(datetime)
    date_str = Calendar.strftime(malaysia_time, "%B %d, %Y")
    time_str = Calendar.strftime(malaysia_time, "%I:%M %p")
    %{date: date_str, time: time_str}
  end

  def format_date_time_12h(naive_datetime) when is_struct(naive_datetime, NaiveDateTime) do
    naive_datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> format_date_time_12h()
  end
end
