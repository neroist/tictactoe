import std/random as std_random
import std/times
import std/json

type
  Mark {.pure.} = enum
    Empty # 0
    X     # 1
    O     # 2

var 
  board: array[3, array[3, Mark]]
  ai: Mark = Mark.O
  random: Mark = Mark.X

  games: int = 19683
  data: JsonNode = newJArray()
  ai_loses, rand_loses, draws: int

proc checkWin(b = board, mark: Mark): bool = 
  ## true if `mark` wins, else false

  # row wins
  for row in b:
    if row == [mark, mark, mark]:
      return true

  # column wins
  for col in 0..2:
    if b[0][col] == mark and b[1][col] == mark and b[2][col] == mark:
      return true

  # diagonal wins
  if b[0][0] == mark and b[1][1] == mark and b[2][2] == mark:
    return true

  if b[0][2] == mark and b[1][1] == mark and b[2][0] == mark:
    return true

proc emptyCells(b = board): int = 
  ## returns amount of empty cells in the board
  
  for row in b:
    for mark in row:
      if mark == Mark.Empty:
        inc result  

proc checkDraw(b = board): bool =
  ## checks if all cells are filled
  
  emptyCells(b) == 0

proc minimax(b: array[3, array[3, Mark]] = board, depth: int = 0, isMaximizing: bool = true, maxDepth: int): float = 
  var b = b

  if b.checkWin(ai):
    return 1 * float(b.emptyCells + 1) # multiply by number of empty cells to
                                       # incentivise quick wins, add by one
                                       # so we don't multiply by zero
  elif b.checkWin(random):
    return -1 * float(b.emptyCells + 1)
  elif b.checkDraw() or depth == maxDepth:
    return 0

  if isMaximizing:
    var maxEval = -Inf # set to ridiculusly low value as each score schould maximize

    for row in 0..2:
      for col in 0..2:
        if b[row][col] == Mark.Empty:
          b[row][col] = ai # set our move 
          var eval = minimax(b, depth + 1, false, max_depth) # run simulation
          b[row][col] = Mark.Empty # undo move
          max_eval = max(max_eval, eval)
    return maxEval
  else:
    var min_eval = Inf # set to ridiculusly high value as each score schould maximize

    for row in 0..2:
      for col in 0..2:
        if b[row][col] == Mark.Empty:
          b[row][col] = random # set player move
          var eval = minimax(b, depth + 1, true, max_depth) # run simulation
          b[row][col] = Mark.Empty # undo move
          min_eval = min(min_eval, eval)
    return min_eval

proc getAiMove(b = board, maxDepth: int): tuple[row, col: int] = 
  var 
    bo = b
    maxscore: float = -Inf

  for row in 0..2:
    for col in 0..2:
      if bo[row][col] != Mark.Empty:
        continue

      bo[row][col] = ai
      let thisscore = minimax(bo, isMaximizing = false, maxDepth = maxDepth)
      bo[row][col] = Mark.Empty
      
      if thisscore > maxscore:
        maxscore = thisscore
        result = (row, col)
  
proc getRandomMove(b = board): tuple[row, col: int] = 
  var 
    moves: seq[tuple[row, col: int]]
    b = b
  
  for row in 0..2:
    for col in 0..2:
      if b[row][col] == Mark.Empty:
        moves.add (row, col)

  return moves.sample()

template gameEnd() =
  if board.checkWin(ai):
    #echo "ai win"
    inc rand_loses

    board = [[Empty, Empty, Empty], [Empty, Empty, Empty], [Empty, Empty, Empty]]
    continue
  elif board.checkWin(random):
    #echo "rand win ", depth, " ", board
    inc ai_loses

    board = [[Empty, Empty, Empty], [Empty, Empty, Empty], [Empty, Empty, Empty]]
    continue
  elif board.checkDraw():
    inc draws

    board = [[Empty, Empty, Empty], [Empty, Empty, Empty], [Empty, Empty, Empty]]
    continue
  

for depth in 1..8:
  let time = cpuTime()

  for i in 1..games:
    gameEnd()

    # random move

    let (r_rand, c_rand) = board.getRandomMove()
    board[r_rand][c_rand] = random

    gameEnd()

    # ai move

    let (r_ai, c_ai) = board.getAiMove(depth)
    board[r_ai][c_ai] = ai

  data.add(%* {
    "depth": depth,
    "wins": games - ai_loses,
    "losses": ai_loses,
    "draws": draws,
    "loss_rate": ai_loses / games,
    "win_rate": (games - ai_loses) / games,
    "time_taken": cpuTime() - time
  })

  echo data.pretty(indent=2)

  draws = 0
  ai_loses = 0
  rand_loses = 0

writeFile("./data.json", data.pretty(indent=2))
