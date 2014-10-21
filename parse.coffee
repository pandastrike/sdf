{readFileSync} = require "fs"

{regexp, word, ws, any, all, many,
  optional, rule, grammar} = require "bartlett"

parse = do ->

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

  eol = regexp /\n*/

  forward = (name) ->
    (s) ->
      g[name](s)

  collapse = (match) ->
    value for value in match.value when value?

  name = rule (regexp /^([^:\?\n]+)/), ({value}) -> value.trim()
  value = rule (regexp /^([^\n]*)/), ({value}) -> value.trim()
  delimiter = regexp /^[:\?]/
  inline = rule (all bol, name, delimiter, value, eol), collapse
  orphan = rule (all bol, value, eol), (match) -> match.value[1]

  # TODO: I don't think the orphan rule ever gets used because
  # array will always match first, but we can't move orphan up
  # because arrays cause the parent rule to fail, and then
  # we can't recover; we need to re-organize the grammar a bit
  # to avoid orphans transforming into single element arrays
  nested = rule (all bol, name, (optional delimiter), eol,
    (indented (any (forward "object"), (forward "array"), orphan))), collapse

  # TODO: this is the hack to get around the above problem, and it
  # really isn't too bad, since this isn't a proper data representation
  array = rule (many orphan), ({value}) ->
    if value.length < 2 then value.toString() else value

  object = rule (many (any nested, inline)), (match) ->
    object = {}
    for [key, value] in match.value
      object[key] = value
    object

  g = {object, array}

  grammar object

module.exports = (path, query) ->
  
  current = root = parse (readFileSync path).toString()

  while query.length > 0 && current?
    key = query.shift()
    current = current[key]

  console.log JSON.stringify(current, null, 2)
