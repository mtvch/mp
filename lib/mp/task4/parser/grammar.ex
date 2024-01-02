defmodule Mp.Task4.Parser.Grammar do
  @moduledoc """
  Описание граматики языка выражений
  """
  import Xpeg

  @doc """
  Возвращает PEG граматику языка выражений
  """
  def peg do
    peg Expr do
      S <- star({' ', '\t', '\r', '\n'})
      Expr <- S * Term * S * star(BinOp) * S
      Term <- NotOp | Const | Var | "(" * S * Expr * S * ")"
      NotOp <- str("!") * Term * fn [x, _op | cs] -> [%Mp.Task4.AstNodes.Not{x: x} | cs] end
      Const <- int({'0', '1'}) * fn [x | cs] -> [%Mp.Task4.AstNodes.Const{value: x} | cs] end
      Var <- str({'a'..'z'}) * fn [x | cs] -> [%Mp.Task4.AstNodes.Var{name: x} | cs] end
      BinOp <- (str({'&', '|'}) | str("->")) * S * Expr * fn [b, op, a | cs] ->
            case op do
              "&" -> [%Mp.Task4.AstNodes.And{a: a, b: b} | cs]
              "|" -> [%Mp.Task4.AstNodes.Or{a: a, b: b} | cs]
              "->" -> [%Mp.Task4.AstNodes.Implication{a: a, b: b} | cs]
            end
          end
    end
  end
end
