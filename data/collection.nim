import std/strutils
import std/random
import std/times
import std/json
import std/math

import termui

import ../common/common

const thisDir = currentSourcePath() & "/../"

var
  computer: Mark = Mark.O
  rnd: Mark = Mark.X

  games: int = 19683
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
  let parts = num.splitDecimal()

  $int(parts.intpart) & "." & ($parts.floatpart & "0".repeat(to))[2..(to + 1)]

template gameEnd() =
  if board.checkWin(computer):
    when not defined(noProgressBar):
      progress.update(i / games, fmt % [$i, $games, $depth, $trunc(cpuTime() - time, 3)])

    board = [[Empty, Empty, Empty], [Empty, Empty, Empty], [Empty, Empty, Empty]]
    continue
  elif board.checkWin(rnd):
    inc ai_loses

    when not defined(noProgressBar):
      progress.update(i / games, fmt % [$i, $games, $depth, $trunc(cpuTime() - time, 3)])

    board = [[Empty, Empty, Empty], [Empty, Empty, Empty], [Empty, Empty, Empty]]
    continue
  elif board.checkDraw():
    inc draws
    
    when not defined(noProgressBar):
      progress.update(i / games, fmt % [$i, $games, $depth, $trunc(cpuTime() - time, 3)])

    board = [[Empty, Empty, Empty], [Empty, Empty, Empty], [Empty, Empty, Empty]]
    continue

proc depthRun(depth: int): JsonNode =
  var
    board: Board
    ai_loses, draws: int
  
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
    "wins": games - ai_loses - draws,
    "losses": ai_loses,
    "draws": draws,
    "loss_rate": ai_loses / games,
    "win_rate": (games - ai_loses - draws) / games,
    "draw_rate": draws / games,
    "time_taken": cpuTime() - time
  }

  when not defined(noProgressBar):
    progress.complete("Finished! Depth: $#; Time: $#" % [$depth, $trunc(cpuTime() - time, 3)])
  else:
    echo result

# SONA WILE
# How does altering the maximum depth of the Minimax algorithm impact how the AI plays

# PILIN MI
# altering the maximum depth of the Minimax algorithm will cause it to play more powerfully,
# winning more games and losing less. However, it will also cause the AI to take more time
# depending on whether the depth was increased or not

# IJO KEPEKEN
# this program, all the files in this directory

# IJO INSA
# 
# MA ONA
# the two bots play 19683 games, a total of 157464 matches
# compiled without any additional compiler flags, on Win 11 intel i5 machine, Nim 2.0
# board starts blank 
# random bot always starts off first
# 
# IJO ANTE
# the depth of the minimax bot, it will start from 1 and go up to 8
#
# KILI
# the loss rate of the minimax bot, and how much time it took for it to complete 19683 matches

# NASIN
# - have two bots: 
#   - one which uses minimax algorithm
#   - and another that plays random moves
# - initiate 19683 games, in which each minimax bot of depths 1-8 plays against the random bot
#   - 19683 is the number of possible tic tac toe boards, disregarding rules of the game
# - collect data from these matches
#   - e.g. time taken to complete the games, and the loss rate of the minimax ai
#
# This will help us determine how altering the maximum depth of the AI affects its gameplay.
# we can analyze and compare the data from the games of AIs of varying depths

# SONA 
# see data.json and attached graphs

# PINI
# Increasing the depth of the AI caused it to win more games, but also use much much more time.
# Similarly, decreasing the depth caused the AI to win less games, and use less time

var time = cpuTime()

for depth in 1..8:
  data.add depthRun(depth)

time = cpuTime() - time

echo "" # newline

termuiLabel("Total time taken (in seconds)", $(time))
termuiLabel("Total time taken (in minutes)", $(time / 60))

writeFile(thisDir & "data.json", $data)
