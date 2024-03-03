import std/strutils
import std/json

const thisDir = currentSourcePath() & "/../"

let data = parseFile(thisDir & "data.json")

var
  header_items: seq[string]
  body: string
  idx: int

  csv: string

for key in data[0].keys:
  header_items.add key

for obj in data:
  for _, val in obj:
    body.add $val

    if idx != header_items.len - 1:
      body.add ","

    inc idx

  body.add "\n"
  idx = 0

csv.add header_items.join(",")
csv.add "\n"
csv.add body

writeFile(thisDir & "data.csv", csv)
