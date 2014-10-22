assert = require "assert"
parse = require "../src/parse"

do ->
  console.log "Simple Key-Value Pairs"
  r = parse """
    a: b
    c: d
    """
  assert.deepEqual r, { a: "b", c: "d" }


do ->
  console.log "Nested Key-Value Pairs"
  r = parse """
    a
      b
        c: d
    """
  assert.deepEqual r, { a: { b: { c: "d" }}}

do ->
  console.log "Simple Lists"
  r = parse """
    a
      b
      c
      d
    """
  assert.deepEqual r, { a: [ "b", "c", "d" ] }


do ->
  console.log "Lists Nested With Objects"
  r = parse """
    a
      b
        c
        d
    """
  assert.deepEqual r, { a: { b: [ "c", "d"]}}
