defmodule Mp.Task4.AstNodeTest do
  use ExUnit.Case

  alias Mp.Task4.AstNode
  alias Mp.Task4.Parser

  describe "#to_string" do
    test "const" do
      {:ok, ast} = Parser.parse("1")
      assert "1" == AstNode.to_str(ast)
    end

    test "neg" do
      {:ok, ast} = Parser.parse("!1")
      assert "!1" == AstNode.to_str(ast)
    end

    test "conjunction" do
      {:ok, ast} = Parser.parse("1&0")
      assert "1 & 0" == AstNode.to_str(ast)
    end

    test "neg + conj" do
      {:ok, ast} = Parser.parse("!1&0")
      assert "!1 & 0" == AstNode.to_str(ast)
    end

    test "neg + conj + parenthesis" do
      {:ok, ast} = Parser.parse("!(1&0)")
      assert "!(1 & 0)" == AstNode.to_str(ast)
    end

    test "implication" do
      {:ok, ast} = Parser.parse("1->0")
      assert "1 -> 0" == AstNode.to_str(ast)
    end

    test "implication + conj" do
      {:ok, ast} = Parser.parse("1->0&1")
      assert "1 -> 0 & 1" == AstNode.to_str(ast)
    end

    test "paranthesis: implication + conj" do
      {:ok, ast} = Parser.parse("(1->0)&1")
      assert "(1 -> 0) & 1" == AstNode.to_str(ast)
    end

    test "variable" do
      {:ok, ast} = Parser.parse("1&x")
      assert "1 & x" == AstNode.to_str(ast)
    end
  end
end
