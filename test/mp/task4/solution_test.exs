defmodule Mp.Task4.ParserTest do
  use ExUnit.Case
  alias Mp.Task4.Parser

  describe "#happy_path" do
    test "const" do
      res = Parser.parse("1")
      assert res.captures == [1]
    end

    test "neg" do
      res = Parser.parse("!1")
      assert res.captures == [{:!, [], [1]}]
    end

    test "conjunction" do
      res = Parser.parse("1&0")
      assert res.captures == [{:&, [], [1, 0]}]
    end

    test "neg + conj" do
      res = Parser.parse("!1&0")
      assert res.captures == [{:&, [], [{:!, [], [1]}, 0]}]
    end

    test "implication" do
      res = Parser.parse("1->0")
      assert res.captures == [{:->, [], [1, 0]}]
    end

    test "implication + conj" do
      res = Parser.parse("1->0&1")
      assert res.captures == [{:->, [], [1, {:&, [], [0, 1]}]}]
    end

    test "paranthesis: implication + conj" do
      res = Parser.parse("(1->0)&1")
      assert res.captures == [{:&, [], [{:->, [], [1, 0]}, 1]}]
    end
  end
end
