defmodule Mp.Task4.Parser.Grammar do
  @moduledoc """
  Описание граматики языка выражений
  """
  import Xpeg

  @doc """
  Возвращает PEG граматику языка выражений
  """
  def peg do
    peg L1 do
      S <- star({' ', '\t', '\r', '\n'})
      L1 <- S * L2 * star(L1Op) * S
      L2 <- L3 * S * star(L2Op) * S
      L3 <- NotOp | Const | Var | "(" * S * L1 * S * ")"
      NotOp <- str("!") * L3 * fn [x, _op | cs] -> [%Mp.Task4.AstNodes.Not{x: x} | cs] end
      Const <- int({'0', '1'}) * fn [x | cs] -> [%Mp.Task4.AstNodes.Const{value: x} | cs] end
      Var <- str({'a'..'z'}) * fn [x | cs] -> [%Mp.Task4.AstNodes.Var{name: x} | cs] end
      L1Op <- str("->") * S * L1 * fn [b, _op, a | cs] -> [%Mp.Task4.AstNodes.Implication{a: a, b: b} | cs] end
      L2Op <- str({'&', '|'}) * S * L1 * fn [b, op, a | cs] ->
            case op do
              "&" -> [%Mp.Task4.AstNodes.And{a: a, b: b} | cs]
              "|" -> [%Mp.Task4.AstNodes.Or{a: a, b: b} | cs]
            end
          end
    end
  end
end
