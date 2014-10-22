{readFileSync} = require "fs"
parse = require "./parse"

module.exports = (path, query) ->

  current = root = parse (readFileSync path).toString()

  while query.length > 0 && current?
    key = query.shift()
    current = current[key]

  console.log JSON.stringify(current, null, 2)
