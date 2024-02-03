import std/strutils
import std/terminal
import std/random
import std/os

randomize()

type
  Mark {.pure.} = enum
    Empty # 0
    X     # 1
    O     # 2

var 
  board: array[3, array[3, Mark]]
  player: Mark = Mark.O
  computer: Mark = Mark.X

proc checkWin(b = board, mark: Mark): bool = 
  ## true if `mark` wins, else false

  # row wins
  for row in b:
    if row == [mark, mark, mark]:
      return true

  # column wins
  for col in 0..2:
    # iterate through col # and check each row for a value at each col
    if b[0][col] == mark and b[1][col] == mark and b[2][col] == mark:
      return true

  # diagonal wins
  if b[0][0] == mark and b[1][1] == mark and b[2][2] == mark:
    # [X _ _] (0, 0)
    # [_ X _] (1, 1)
    # [_ _ X] (2, 2)

    return true

  if b[0][2] == mark and b[1][1] == mark and b[2][0] == mark:
    # [_ _ X] (0, 2)
    # [_ X _] (1, 1)
    # [X _ _] (2, 0)

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

  if b.checkWin(computer):
    return 1 * float(b.emptyCells + 1) # multiply by number of empty cells to
                                       # incentivise quick wins, add by one
                                       # so we don't multiply by zero
  elif b.checkWin(player):
    return -1 * float(b.emptyCells + 1)
  elif b.checkDraw() or depth == maxDepth:
    return 0

  if isMaximizing:
    var maxEval = -Inf # set to ridiculusly low value as each score schould maximize

    for row in 0..2:
      for col in 0..2:
        if b[row][col] == Mark.Empty:
          b[row][col] = computer # set our move 
          var eval = minimax(b, depth + 1, false, max_depth) # run simulation
          b[row][col] = Mark.Empty # undo move
          max_eval = max(max_eval, eval)
    return maxEval
  else:
    var min_eval = Inf # set to ridiculusly high value as each score schould maximize

    for row in 0..2:
      for col in 0..2:
        if b[row][col] == Mark.Empty:
          b[row][col] = player # set player move
          var eval = minimax(b, depth + 1, true, max_depth) # run simulation
          b[row][col] = Mark.Empty # undo move
          min_eval = min(min_eval, eval)
    return min_eval

proc getOptimalMove(b = board, maxDepth: int, mark = computer): tuple[row, col: int] = 
  if b.emptyCells == 9:
    return (rand(0..2), rand(0..2))

  var 
    bo = b
    pcI = computer
    maxscore: float = -Inf

  computer = mark

  for row in 0..2:
    for col in 0..2:
      if bo[row][col] != Mark.Empty:
        continue

      bo[row][col] = computer
      let thisscore = minimax(bo, isMaximizing = false, maxDepth = maxDepth)
      bo[row][col] = Mark.Empty
      
      if thisscore > maxscore:
        maxscore = thisscore
        result = (row, col)
  
  computer = pcI

template red(str: string): string =
  "\e[31m" & str & "\e[0m"

template blue(str: string): string =
  "\e[36m" & str & "\e[0m"

template gameEnded(): bool =
  board.checkWin(computer) or board.checkWin(player) or board.checkDraw()

proc clear() =
  eraseScreen()
  setCursorPos(0, 0)

proc printBoard(b = board, clear_screen: bool) = 
  ## print board to terminal
  ## 
  ##  X | O | X 
  ## ---+---+---
  ##  O | X | O 
  ## ---+---+---
  ##  X | O | X 
  
  if clear_screen:
    clear()
  
  for row in 0..2:
    stdout.write " " # pad each row

    for col in 0..2:
      if col != 0: # make sure we dont write a line behind the first column
        stdout.write "| "

      case b[row][col]
      of Mark.Empty:
        stdout.write " ", " " # write empty cell, then padding
      of Mark.X:
        stdout.write red($b[row][col]), " " #
      else:
        stdout.write blue($b[row][col]), " " #
    
    if row != 2: # make sure we dont write a line below the last row
      stdout.write "\n---+---+---"

    stdout.write "\n" # we always need a newline after each row

proc input(str: string): string = 
  ## python-like input function

  stdout.write str
  stdout.flushFile()
  stdin.readLine()

proc play() = 
  clear()

  echo "Welcome! \n"
  let max_depth = parseInt input("Max Depth? ")
  let playerstr = input("Who do you want to play as? ")
                    .strip()
                    .toLowerAscii()
  let gofirst = not parseBool input("Do you want to go first? ")
  
  if playerstr == "x":
    player = Mark.X
    computer = Mark.O
  elif playerstr == "o":
    player = Mark.O
    computer = Mark.X
  else:
    echo "Invalid input"
    return

  if gofirst:
    let move = getOptimalMove(board, max_depth) # get best move
    board[move.row][move.col] = computer # set computer move

  while not gameEnded():
    printBoard(clear_screen=true)

    echo "\n"

    let
      row = parseInt input("What row do you want to play on? ")
      col = parseInt input("What column do you want to play on? ")

    board[row-1][col-1] = player # set player move
    
    printBoard(clear_screen=true)
    echo "\n"
    
    let best_move = getOptimalMove(board, max_depth) # get best move

    sleep 500 # wait a bit

    if not gameEnded():
      board[best_move.row][best_move.col] = computer # set computer move

  printBoard(clear_screen=true)
  echo "\n"

  if board.checkWin(computer):
    echo "Computer Won!"
  elif board.checkWin(player):
    echo "You won!"
  else:
    echo "Draw!"
#          <label for="depth">AI Max Depth: </label>
#          <input type="number" name="depth" min="1" max="20" value="10" required>
when isMainModule:
  play()