defmodule Tester.Deadline.InvalidConversion do
  defexception message: "Deadline is in the past"
end

defmodule Tester.Deadline do
  alias Tester.Deadline.InvalidConversion

  @type t() :: DateTime.t()

  @spec make_deadline(non_neg_integer(), System.time_unit()) :: t()
  def make_deadline(amount_to_add, unit) do
    DateTime.utc_now()
    |> DateTime.add(amount_to_add, unit)
  end

  @spec from_timeout(timeout()) :: t()
  def from_timeout(timeout) do
    make_deadline(timeout, :millisecond)
  end

  @spec to_timeout!(t()) :: timeout()
  def to_timeout!(deadline) do
    case DateTime.diff(deadline, DateTime.utc_now(), :millisecond) do
      invalid when invalid < 0 -> raise InvalidConversion
      good -> good
    end
  end

  @spec to_timeout_or_zero(t()) :: timeout()
  def to_timeout_or_zero(deadline) do
    try do
      to_timeout!(deadline)
    rescue
      InvalidConversion ->
        0
    end
  end

  @spec to_iso8601(t()) :: String.t()
  def to_iso8601(deadline) do
    deadline
    |> DateTime.shift_zone!("Etc/UTC")
    |> DateTime.to_iso8601()
  end

  @spec is_reached(t()) :: boolean()
  def is_reached(deadline) do
    DateTime.compare(deadline, DateTime.utc_now()) != :lt
  end
end
