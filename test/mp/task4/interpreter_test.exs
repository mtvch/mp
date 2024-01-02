defmodule Mp.Task4.InterpreterTest do
  use ExUnit.Case
  alias Mp.Task4.Interpreter

  describe "#happy_path" do
    test "const" do
      assert {:ok, 1} = Interpreter.run("1")
    end

    test "neg" do
      assert {:ok, 0} == Interpreter.run("!1")
    end

    test "conjunction" do
      assert {:ok, 0} == Interpreter.run("1&0")
    end

    test "neg + conj" do
      assert {:ok, 0} == Interpreter.run("!1&0")
    end

    test "neg + conj + parenthesis" do
      assert {:ok, 1} == Interpreter.run("!(1&0)")
    end

    test "implication" do
      assert {:ok, 0} == Interpreter.run("1->0")
    end

    test "implication + conj" do
      assert {:ok, 0} == Interpreter.run("1->0&1")
    end

    test "implication + conj #2" do
      assert {:ok, 1} == Interpreter.run("1->1&1")
    end

    test "paranthesis: implication + conj" do
      assert {:ok, 0} == Interpreter.run("(1->0)&1")
    end

    test "variable" do
      assert {:ok, 1} == Interpreter.run("1&x", %{"x" => 1})
    end

    test "variable #1" do
      assert {:ok, 0} == Interpreter.run("1&x", %{"x" => 0})
    end

    test "spaces" do
      assert {:ok, 0} == Interpreter.run(" ( 1 -> 0 ) & 1 ")
    end
  end
end
