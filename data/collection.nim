import std/strutils
import std/random
import std/times
import std/json
import std/math

import termui # https://github.com/neroist/nim-termui

import ../common/common

const 
  thisDir = currentSourcePath() & "/../"

  games {.intdefine.}: int = 19683
  max_depth {.intdefine.}: int = 8

var
  computer: Mark = Mark.O
  rnd: Mark = Mark.X

  data: JsonNode = newJArray()

proc getRandomMove(b: Board): tuple[row, col: int] = 
  var 
    moves: seq[tuple[row, col: int]]
    b = b
  
  for row in 0..2:
    for col in 0..2:
      if b[row][col] == Mark.Empty:
        moves.add (row, col)

  return moves.sample()

proc trunc(num: float, to: int): string =
  ## Trunicate float to `to` decimal points

  let parts = num.splitDecimal()

  $int(parts.intpart) & "." & ($parts.floatpart & "0".repeat(to))[2..(to + 1)]

template gameEnd() =

  template procedure() =
    
    # update the progess bar, when enabled
    when not defined(noProgressBar):
      progress.update(i / games, fmt % [$i, $games, $depth, $trunc(cpuTime() - time, 3)])

    # reset board
    board = [[Empty, Empty, Empty], [Empty, Empty, Empty], [Empty, Empty, Empty]]
    
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

proc depthRun(depth: int): JsonNode =
  var
    board: Board
    ai_losses, draws: int
  
  let 
    time = cpuTime()
  
  when not defined(noProgressBar):
    let fmt = "$#/$# games; Depth: $#; Time: $#"
    let progress = termuiProgress(fmt % [$0, $games, $depth, $trunc(cpuTime() - time, 3)])

  for i in 1..games:
    gameEnd()

    # random move

    let (r_rand, c_rand) = board.getRandomMove()
    board[r_rand][c_rand] = rnd

    gameEnd()

    # ai move

    let (r_ai, c_ai) = board.getOptimalMove(computer, rnd, depth)
    board[r_ai][c_ai] = computer

  result = %* {
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

  when not defined(noProgressBar):
    progress.complete("Finished! Depth: $#; Time: $#" % [$depth, $trunc(cpuTime() - time, 3)])
  else:
    echo result

var time = cpuTime()

for depth in 1..(max_depth):
  data.add depthRun(depth)

time = cpuTime() - time

echo "" # newline

termuiLabel("Total time taken (in seconds)", $(time))
termuiLabel("Total time taken (in minutes)", $(time / 60))

writeFile(thisDir & "data.json", $data)
