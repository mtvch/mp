defmodule Mp.Task4.SolutionTest do
  use ExUnit.Case

  alias Mp.Task4.Solution

  describe "#happy_path" do
    test "implication" do
      assert {:ok, %{result: 1, dnf: "!a & !b"}} ==
               Solution.run("(a->b)&!(a|b)", %{"a" => 0, "b" => 0})

      assert {:ok, %{result: 0, dnf: "!a & !b"}} ==
               Solution.run("(a->b)&!(a|b)", %{"a" => 1, "b" => 0})
    end

    test "wiki example" do
      assert {:ok, %{result: 0, dnf: "x & !y & z | x & !y"}} ==
               Solution.run("!((x->y)|!(y->z))", %{"x" => 0, "y" => 0, "z" => 0})

      assert {:ok, %{result: 1, dnf: "x & !y & z | x & !y"}} ==
               Solution.run("!((x->y)|!(y->z))", %{"x" => 1, "y" => 0, "z" => 0})
    end

    test "contradiction" do
      assert {:ok, %{result: 0, dnf: "0"}} == Solution.run("x & !x", %{"x" => 1})
    end

    test "remove 'true' in conjunction" do
      assert {:ok, %{result: 1, dnf: "x"}} == Solution.run("x & 1", %{"x" => 1})
    end

    test "remove single 'false' conjunction" do
      assert {:ok, %{result: 0, dnf: "0"}} == Solution.run("x & 0", %{"x" => 1})
    end

    test "remove 'false' conjunction" do
      assert {:ok, %{result: 1, dnf: "x"}} == Solution.run("x | x & 0", %{"x" => 1})
    end
  end

  describe "#sad_path" do
    test "var not defined" do
      assert {:error, {:var_not_defined, "z"}} ==
               Solution.run("!((x->y)|!(y->z))", %{"x" => 0, "y" => 0})
    end

    test "not valid expression" do
      assert {:error, :parsing_error} == Solution.run("!", %{})
    end
  end
end
