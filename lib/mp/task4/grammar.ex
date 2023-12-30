defmodule Mp.Task4.Grammar do
  import Xpeg

  def peg do
    peg L1 do
      L1 <- L2 * star(L1Op)
      L2 <- L3 * star(L2Op)
      L3 <- NegOp | Const | "(" * L1 * ")"
      NegOp <- str("!") * L3 * fn [x, op | cs] -> [{String.to_atom(op), [], [x]} | cs] end
      Const <- int({'0', '1'})
      L1Op <- str("->") * L1 * fn [b, op, a | cs] -> [{String.to_atom(op), [], [a, b]} | cs] end
      L2Op <- str({'&', '|'}) * L1 * fn [b, op, a | cs] -> [{String.to_atom(op), [], [a, b]} | cs] end
    end
  end
end
