defmodule Mp.Task4.ParserTest do
  use ExUnit.Case
  alias Mp.Task4.AstNodes.And
  alias Mp.Task4.AstNodes.Const
  alias Mp.Task4.AstNodes.Implication
  alias Mp.Task4.AstNodes.Not
  alias Mp.Task4.AstNodes.Or
  alias Mp.Task4.AstNodes.Var
  alias Mp.Task4.Parser

  describe "#happy_path" do
    test "const" do
      assert {:ok, %Const{value: 1}} = Parser.parse("1")
    end

    test "neg" do
      assert {:ok, %Not{x: %Const{value: 1}}} == Parser.parse("!1")
    end

    test "conjunction" do
      assert {:ok,
              %And{
                a: %Const{value: 1},
                b: %Const{value: 0}
              }} == Parser.parse("1&0")
    end

    test "or" do
      assert {:ok,
              %Or{
                a: %Const{value: 1},
                b: %Const{value: 0}
              }} == Parser.parse("1|0")
    end

    test "neg + conj" do
      assert {:ok,
              %And{
                a: %Not{x: %Const{value: 1}},
                b: %Const{value: 0}
              }} == Parser.parse("!1&0")
    end

    test "implication" do
      assert {:ok,
              %Implication{
                a: %Const{value: 1},
                b: %Const{value: 0}
              }} == Parser.parse("1->0")
    end

    test "implication + conj" do
      assert {:ok,
              %Implication{
                a: %Const{value: 1},
                b: %And{
                  a: %Const{value: 0},
                  b: %Const{value: 1}
                }
              }} == Parser.parse("1->0&1")
    end

    test "paranthesis: implication + conj" do
      assert {:ok,
              %And{
                a: %Implication{
                  a: %Const{value: 1},
                  b: %Const{value: 0}
                },
                b: %Const{value: 1}
              }} == Parser.parse("(1->0)&1")
    end

    test "variable" do
      assert {:ok, %And{a: %Const{value: 1}, b: %Var{name: "x"}}} == Parser.parse("1&x")
    end

    test "spaces" do
      assert {:ok,
              %And{
                a: %Implication{
                  a: %Const{value: 1},
                  b: %Const{value: 0}
                },
                b: %Const{value: 1}
              }} == Parser.parse(" ( 1 -> 0 ) & 1 ")
    end
  end
end
