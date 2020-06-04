defmodule Csc430assignment5 do
  @moduledoc """
  Documentation for `Csc430assignment5`.
  """

  @doc """
  Assignment 5 - Translating Assignment 3 into Elixir

  ## Examples

      iex> Csc430assignment5.interp([:IfC, [:IdC, :t], [:NumC, 5], [:NumC, -1]], Csc430assignment5.makeEnv())
      [:NumV, 5]

  """
  # an ExprC can be one of
  # - [:NumC, double]
  # - [:StrC, string]
  # - [:IdC, atom]
  # - [:IfC, ExprC, ExprC, ExprC]
  # - [:LamC, [atom ...], ExprC]

  # a Value can be one of
  # - [:NumV, double]
  # - [:StrV, string]
  # - [:BoolV, boolean]
  # - [:CloV, [atom ...], ExprC, Env]
  # - [:PrimV, [atom ...], ExprC]

  # a Binding is a
  # - [atom, Value]

  # an Env (environment) is a
  # - [Binding ...]

  # given an expr : ExprC and an env : Env
  # interp evaluates the expr in env and returns a value
  def interp(expr, env) do
    case expr do
      [:NumC, n] -> [:NumV, n]
      [:StrC, s] -> [:StrV, s]
      [:IdC, s] -> lookup(s, env)
      [:IfC, tst, then, els] -> ifc(interp(tst, env), then, els, env)
      [:LamC, args, body] -> [:CloV, args, body]
    end
  end

  def ifc(tstRes, then, els, env) do
    case tstRes do
      [:BoolV, b] ->
        if b do
          interp(then, env)
        else
          interp(els, env)
        end
      _ -> raise "if given a test that did not evaluate to a boolean"
    end
  end

  def lookup(s, env) do
    [_, res] = Enum.find(env, fn([k, _]) ->
      if k == s do
        true
      end
    end)
    if !res do
      raise "AQSE lookup: unbound identifier"
    end
    res
  end

  def makeEnv() do
    [
      [:t, [:BoolV, true]],
      [:f, [:BoolV, false]],
      [:+, [:PrimV, :+]],
      [:-, [:PrimV, :-]],
      [:*, [:PrimV, :*]],
      [:/, [:PrimV, :/]],
      [:<=, [:PrimV, :<=]],
      [:equal, [:PrimV, :equal]],
      [:error, [:PrimV, :error]]
    ]
  end
end
