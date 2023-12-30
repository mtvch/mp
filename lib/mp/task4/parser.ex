defmodule Mp.Task4.Parser do
  alias Mp.Task4.Grammar
  @peg Grammar.peg()

  def parse(str) do
    Xpeg.match(@peg, str)
  end
end
