defmodule Csc430assignment5Test do
  use ExUnit.Case
  doctest Csc430assignment5

  # to run tests
  # run: mix test
  # within the project directory

  test "interpret a NumC" do
    assert Csc430assignment5.interp([:NumC, 5], Csc430assignment5.makeEnv()) == [:NumV, 5]
  end

  test "interpret a StrC" do
    assert Csc430assignment5.interp([:StrC, "hello"], Csc430assignment5.makeEnv()) == [:StrV, "hello"]
  end

  test "interpret an IdC" do
    assert Csc430assignment5.interp([:IdC, :t], Csc430assignment5.makeEnv()) == [:BoolV, true]
  end

  test "interpret an IfC" do
    assert Csc430assignment5.interp(
      [:IfC, [:IdC, :t], [:NumC, 5], [:NumC, -1]], 
      Csc430assignment5.makeEnv()) == [:NumV, 5]
  end

  test "interpret a LamC" do
    assert Csc430assignment5.interp([:LamC, :t], Csc430assignment5.makeEnv()) == [:CloV, true]
  end

end
