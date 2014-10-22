{regexp, word, ws, any, all, many,
  optional, rule, grammar} = require "bartlett"

module.exports = do ->

  tabs = 0

  indented = (p) ->
    (s) ->
      tabs++
      match = p(s)
      tabs--
      match

  spaces = regexp /^([ ]*)/

  bol = (s) ->
    match = spaces(s)
    if match?
      {value, rest} = match
      if value.length == tabs * 2
        {rest}

  eol = regexp /\n+|$/

  forward = (fn) ->
    (s) -> fn()(s)

  collapse = ({value}) -> v for v in value when v?

  name = rule (regexp /^([^:\?\n]+)/), ({value}) -> value.trim()
  atom = rule (regexp /^([^\n]+)/), ({value}) -> value.trim()
  # orphan = rule , (m) -> (collapse m)[0]
  delimiter = regexp /^[:\?]/
  nested = rule (all bol, name, (optional delimiter), eol,
    (indented (forward (-> value)))), collapse
  inline = rule (all bol, name, delimiter, atom, eol), collapse
  pair = any inline, nested
  array = many (rule (all bol, atom, eol), (m) -> (collapse m)[0])
  object = rule (many pair), ({value}) ->
    result = {}
    (result[k] = v) for [k,v] in value
    result
  value = any object, array
  grammar value
