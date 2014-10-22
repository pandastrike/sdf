# Simple Data Format

## Background

There are a lot of very nice data formats out there. JSON has become the _lingua franca_ of the Web. YAML is a bit easier for humans to read and write. CSON is kind of in-between somewhere. Yet&hellip;I found myself wanting something nicer. Something leaner than YAML. That maybe could be the starting point for a very lean CSON implementation. That might lend itself to other data formats.

I've been thinking about this [for some time now][0]. I've had partial implementatios floating around, but this is currently my favorite. It's written in CoffeeScript, checking in at less than 100 lines of code. It's very alpha, meaning the only tests at the moment is my own use of it. It's definitely got some issues, like not being able to use `:` or `?` in key names.

[0]:http://ajaxian.com/archives/really-simple-data-yayaml

## Quick Start

But it's a start. And it's pretty cool already. Here, for example, is a simple employee database:

```
John
  birthday: November 9th
  start date: August 1st, 2014
Susie
  birthday: February 2nd
  start date: September 4th, 2013
  hobbies
    ice-skating
    snow boarding
```

Okay, that's a goofy example, but you get the idea. I can use the `sdf` tool installed with the NPM to query the database by key:

```
$ sdf team.sdf John birthday
"November 9th"
$ sdf team.sdf Susie 'start date'
"September 4th, 2013"
```

SDF has implicit arrays, meaning a bunch of values with no keys is automatically an array:

```
$ sdf team.sdf Susie hobbies
['ice-skating', 'snow boarding']
```

(Yes, I know, I know. The `sdf` tool returns values as JSON. That comes in handy, as you'll see below. However, it would probably make more sense to have a `--json` flag or something.)

## Installation

`npm install sdf`

If you want to use the `sdf` CLI, use:

`npm install sdf -g`

## Implementation

SDF is implemented using [Bartlett][], which is a partially implemented recursive decent combinator library. That's part of how the SDF parser can be implemented in so few lines of code. More work is needed on this as well, but, again, it's a start.

[Bartlett]:https://github.com/pandastrike/bartlett

I use SDF to manage my own little databases: todo lists, passwords (on an encrypted drive), and other details. It's super easy to add new bits of data:

```
$ cat >> todo.sdf
SDF
  add tests
```

And now you can query that with `sdf`:

```
$ sdf todo.sdf SDF
"add tests"
```

## Format

The format can be confusing exactly because it's so flexible. The main thing is that it's whitespace significant. Nested lines become part of the parent property, either in the form of an object or an array.

### Example 1

```
a: b
c: d
```

yields the object:

```json
{ "a": "b", "c": "d" }
```

This yields the same thing:

```
a
 b
c
 d
```

### Example 2

You can nest idenfinitely:

```
a
 b
  c
```

yields

```json
{"a": {"b": "c"}}
```

and is the same as:

```
a
  b: c
```

### Example 3

You can add colons at the end of keys if it makes you feel more orderly:

```
a:
  b: c
```

However, you can't do nested inline objects:

```
a: b: c
```

Multiple lines with no keys will turn into an array:

```
a
  b
  c
```

becomes

```json
{ "a": ["b", "c"]}
```

## Limitations

* At the moment there are no comments

* There's no way to have a one item array

* Key names can't use `:` or `?` (and, by the way, `?` works as a key delimiter just like ':')

* There's no error reporting, though it wouldn't be difficult to add

* There's no formal definition of the grammar

* There are only object, array, and string data types

* The API is not very useful since it's entirely focused on the `sdf` CLI at the moment

* No tests yet

## Dumping to JSON

You can keep your files in SDF and dump them to JSON just by providing no arguments.
