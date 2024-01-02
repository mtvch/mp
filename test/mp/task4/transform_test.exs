defmodule Mp.Task4.TransformTest do
  use ExUnit.Case

  alias Mp.Task4.AstNode
  alias Mp.Task4.Interpreter
  alias Mp.Task4.Parser
  alias Mp.Task4.Transform

  test "implication" do
    expr = "(a->b)&!(a|b)"
    dnf_expr = "!a & !b"

    {:ok, ast} = Parser.parse(expr)
    assert dnf_expr == ast |> Transform.to_dnf() |> AstNode.to_str()

    for a <- [0, 1], b <- [0, 1] do
      assert Interpreter.run(expr, %{"a" => a, "b" => b}) ==
               Interpreter.run(dnf_expr, %{"a" => a, "b" => b})
    end
  end

  test "wiki example" do
    expr = "!((x->y)|!(y->z))"
    dnf_expr = "x & !y & z | x & !y"

    {:ok, ast} = Parser.parse(expr)
    assert dnf_expr == ast |> Transform.to_dnf() |> AstNode.to_str()

    for x <- [0, 1], y <- [0, 1], z <- [0, 1] do
      bindings = %{"x" => x, "y" => y, "z" => z}
      assert Interpreter.run(expr, bindings) == Interpreter.run(dnf_expr, bindings)
    end
  end

  test "contradiction" do
    expr = "x&!x"
    dnf_expr = "0"

    {:ok, ast} = Parser.parse(expr)
    assert dnf_expr == ast |> Transform.to_dnf() |> AstNode.to_str()
  end

  test "true" do
    expr = "x&1"
    dnf_expr = "x"

    {:ok, ast} = Parser.parse(expr)
    assert dnf_expr == ast |> Transform.to_dnf() |> AstNode.to_str()
  end

  test "false" do
    expr = "x&0"
    dnf_expr = "0"

    {:ok, ast} = Parser.parse(expr)
    assert dnf_expr == ast |> Transform.to_dnf() |> AstNode.to_str()
  end

  test "remove false" do
    expr = "x | y&0"
    dnf_expr = "x"

    {:ok, ast} = Parser.parse(expr)
    assert dnf_expr == ast |> Transform.to_dnf() |> AstNode.to_str()
  end
end
