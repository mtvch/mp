# Used by "mix format"
[
  inputs:
    Enum.flat_map(
      ["{mix,.formatter,.recode,.credo}.exs", "{config,lib,test}/**/*.{ex,exs}"],
      &Path.wildcard(&1, match_dot: true)
    ) -- ["lib/mp/task4/parser/grammar.ex"]
]
