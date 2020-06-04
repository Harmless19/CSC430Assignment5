defmodule Csc430assignment5 do
  @moduledoc """
  Documentation for `Csc430assignment5`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Csc430assignment5.hello()
      :world

  """
  # how to call interp
  # M.interp([:IdC, :t], M.makeEnv())
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
    res = Enum.find(env, fn([k, v]) ->
      if k == s do
        v
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
