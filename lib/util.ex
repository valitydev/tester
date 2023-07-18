defmodule Tester.Util do
  @spec make_random_string() :: String.t()
  def make_random_string() do
    Base.hex_encode32(:crypto.strong_rand_bytes(8), case: :lower, padding: false)
  end
end
