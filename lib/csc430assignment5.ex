defmodule Csc430assignment5 do
  # an ExprC can be one of
  # - [:NumC, double]
  # - [:StrC, string]
  # - [:IdC, atom]
  # - [:IfC, ExprC, ExprC, ExprC]
  # - [:LamC, [atom ...], ExprC]
  @type exprC :: numC | strC
  @type numC :: {n :: float}
  @type strC :: {n :: float}

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
      [:LamC, args, body] -> [:CloV, args, body, env]
      [:AppC, fun, args] -> appc(interp(fun, env), args, env)
    end
  end

  # given tst
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

  # given fVal : CloV, args : [ExprC ...]
  # return the value that results from evaluating the appc
  def appc([:CloV, params, body, env], args, cEnv) do
    cond do 
      Enum.count(params) == Enum.count(args) ->
        interp(body, extendEnv(env, params, Enum.map(args, fn(a) -> interp(a, cEnv) end)))
    end
  end

  # given an env : Env, params : (Listof Atom), args : (Listof Value)
  # extend the current environment for all params and their corresponding args
  def extendEnv(env, [firstParams | restParams], [firstArgs | restArgs]) do
    [[firstParams, firstArgs] | extendEnv(env, restParams, restArgs)]
  end

  # base case for extendEnv
  # when the params and args lists are empty return the given env
  def extendEnv(env, [], []) do
    env
  end
      
  # given prim : PrimV, args : (Listof ExprC), cEnv : Env
  # choose the primitive operator to apply based on prim
  def appc([:PrimV, prim], args, cEnv) do
    cond do
      prim == :error and Enum.count(args) == 1 -> 
        raise "An error has occured"
      Enum.count(args) == 2 ->
        case prim do
          :+ -> numPrim(:+, fn(x, y) -> x + y end, Enum.map(args, fn(a) -> interp(a, cEnv) end))
          :- -> numPrim(:-, fn(x, y) -> x - y end, Enum.map(args, fn(a) -> interp(a, cEnv) end))
          :* -> numPrim(:*, fn(x, y) -> x * y end, Enum.map(args, fn(a) -> interp(a, cEnv) end))
          :/ -> numPrim(:/, fn(x, y) -> x / y end, Enum.map(args, fn(a) -> interp(a, cEnv) end))
          :<= -> lteqPrim(Enum.map(args, fn(a) -> interp(a, cEnv) end))
          :equal? -> equalPrim(Enum.map(args, fn(a) -> interp(a, cEnv) end))
        end
      true -> raise "AQSE Wrong number of arguments given for primitive"
    end
  end

  # given op : symbol, fun : (float float -> float), x : NumV, y : NumV
  # perform the given numeric operation on the values of x and y
  # error on divison by zero
  def numPrim(op, fun, [[:NumV, x], [:NumV, y]]) do
    if op == :/ and y == 0 do
      raise "AQSE division by 0"
    end
    [:NumV, fun.(x, y)]
  end

  def numPrim(_op, _fun, _other) do
    raise ArithmeticError, "numPrim was not given two numbers"
  end

  # determine equality between two Values
  # [tx, x] is a Value and [ty, y] is a Value 
  def equalPrim([[tx, x], [ty, y]]) do
    cond do
      (tx == :NumV and ty == :NumV) or
      (tx == :StrV and ty == :StrV) or
      (tx == :BoolV and ty == :BoolV) ->
        [:BoolV, x == y]
      true -> [:BoolV, false]
    end
  end

  # determines if [tx, x] : Value is less than or equal to [ty, y] : Value
  def lteqPrim([[tx, x], [ty, y]]) do
    cond do
      (tx == :NumV and ty == :NumV) ->
        [:BoolV, x <= y]
    end
  end

  # searches for s : Symbol in the given env : Env
  def lookup(s, env) do
    try do
      [_, res] = Enum.find(env, fn([k, _]) ->
        if k == s do
          true
        end
      end)
      res
    rescue
      e in MatchError ->
        raise RuntimeError, "AQSE lookup: unbound identifier #{s}"
    end
  end

  # constructs the baseEnv and returns an Env
  def makeEnv() do
    [
      [:t, [:BoolV, true]],
      [:f, [:BoolV, false]],
      [:+, [:PrimV, :+]],
      [:-, [:PrimV, :-]],
      [:*, [:PrimV, :*]],
      [:/, [:PrimV, :/]],
      [:<=, [:PrimV, :<=]],
      [:equal?, [:PrimV, :equal?]],
      [:error, [:PrimV, :error]]
    ]
  end
end
