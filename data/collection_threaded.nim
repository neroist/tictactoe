import std/strutils
import std/random
import std/times
import std/json
import std/math
import std/os

import termui # https://github.com/neroist/nim-termui@#head

import ../common/common

const 
  thisDir: string = currentSourcePath().parentDir()

  games {.intdefine.}: int = 19683
  maxDepth {.intdefine.}: int = 8

var
  computer: Mark = Mark.O
  rnd: Mark = Mark.X

  data: JsonNode = newJArray()
  dataPtr: pointer = addr data

  threads: array[0..(max_depth - 1), Thread[int]]

proc getRandomMove(b: Board): tuple[row, col: int] = 
  var 
    moves: seq[tuple[row, col: int]]
    b = b
  
  for row in 0..2:
    for col in 0..2:
      if b[row][col] == Mark.Empty:
        moves.add (row, col)

  return moves.sample()

template timeit(code: untyped): float = 
  var time = cpuTime()

  code

  cpuTime() - time

template gameEnd() =

  template procedure() =

    # reset board
    board = [[Empty, Empty, Empty],
             [Empty, Empty, Empty],
             [Empty, Empty, Empty]]
    
    # continue on with next game
    continue
    
  if board.checkWin(computer):
    procedure()
  elif board.checkWin(rnd):
    inc ai_losses

    procedure()
  elif board.checkDraw():
    inc draws

    procedure()

proc depthRun(depth: int) {.thread.} =
  var
    board: Board
    ai_losses, draws: int

    res: JsonNode = cast[ptr JsonNode](dataPtr)[]
  
  let 
    time = cpuTime()
  
  for i in 1..games:
    gameEnd()

    # random move

    let (r_rand, c_rand) = board.getRandomMove()
    board[r_rand][c_rand] = rnd

    gameEnd()

    # ai move

    let (r_ai, c_ai) = board.getOptimalMove(computer, rnd, depth)
    board[r_ai][c_ai] = computer

  res.add: %* {
    "depth": depth,
    "wins": games - ai_losses - draws,
    "losses": ai_losses,
    "draws": draws,
    "loss_rate": ai_losses / games,
    "win_rate": (games - ai_losses - draws) / games,
    "draw_rate": draws / games,
    "time_taken": cpuTime() - time,
    "games": games
  }

  dataPtr = addr res

  echo res[^1].pretty

for depth in 1..max_depth:
  createThread threads[depth - 1], depthRun, depth

let time = timeit:
  joinThreads(threads)

echo "" # newline

termuiLabel("Total time taken (in seconds)", $(time))
termuiLabel("Total time taken (in minutes)", $(time / 60))

writeFile(thisDir / "data.json", $data)
