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

  test "interpret an IdC that does not exist in the env" do
    assert_raise RuntimeError, "AQSE lookup: unbound identifier x", 
    fn -> Csc430assignment5.interp([:IdC, :x], Csc430assignment5.makeEnv()) end
  end

  test "interpret an IfC" do
    assert Csc430assignment5.interp(
      [:IfC, [:IdC, :t], [:NumC, 5], [:NumC, -1]], 
      Csc430assignment5.makeEnv()) == [:NumV, 5]
  end

  test "interpret a LamC" do
    assert Csc430assignment5.interp([:LamC, [:x], [:IdC, :x]], Csc430assignment5.makeEnv()) == [:CloV, [:x], [:IdC, :x], Csc430assignment5.makeEnv()]
  end

  test "interpret an AppC where fun is PrimV" do
    assert Csc430assignment5.interp([:AppC, [:IdC, :+], [[:NumC, 5],[:NumC, 7]]], Csc430assignment5.makeEnv()) == [:NumV, 12]
  end

  test "interpret an AppC where fun is PrimV + but not given two numbers" do
    assert_raise ArithmeticError, "numPrim was not given two numbers",
    fn -> Csc430assignment5.interp([:AppC, [:IdC, :+], [[:NumC, 5],[:StrC, 7]]], Csc430assignment5.makeEnv()) end
  end

  test "interpret equality of two ExprC" do
    assert Csc430assignment5.interp([:AppC, [:IdC, :equal?], [[:NumC, 5], [:NumC, 5]]], Csc430assignment5.makeEnv()) == [:BoolV, true]
  end

  test "interpret equality of two ExprC - mismatching types" do
    assert Csc430assignment5.interp([:AppC, [:IdC, :equal?], [[:StrC, "test"], [:NumC, 5]]], Csc430assignment5.makeEnv()) == [:BoolV, false]
  end

  test "interpret <= of two ExprC: 5 <= 7" do
    assert Csc430assignment5.interp([:AppC, [:IdC, :<=], [[:NumC, 5], [:NumC, 7]]], Csc430assignment5.makeEnv()) == [:BoolV, true]
  end

  test "interpret <= of two ExprC: 10 <= 7" do
    assert Csc430assignment5.interp([:AppC, [:IdC, :<=], [[:NumC, 10], [:NumC, 7]]], Csc430assignment5.makeEnv()) == [:BoolV, false]
  end

  test "interpret an AppC" do
    assert Csc430assignment5.interp([:AppC, [:LamC, [:x, :y], [:AppC, [:IdC, :+], [[:IdC, :x], [:IdC, :y]]]], [[:NumC, 3], [:NumC, 4]]],
    Csc430assignment5.makeEnv()) == [:NumV, 7]
  end

end
