import std/strutils
import std/dom

import ./confetti

type
  Mark {.pure.} = enum
    Empty # 0
    X     # 1
    O     # 2

  Board = array[3, array[3, Mark]]

var
  maxConfetti {.exportc.} = 400
  minConfetti {.exportc.} = 200

var 
  board: Board
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

proc minimax(b: Board = board, depth: int = 0, isMaximizing: bool = true, maxDepth: int): float = 
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
    var maxEval = -Inf # set to ridiculusly low value so each score maximizes

    for row in 0..2:
      for col in 0..2:
        if b[row][col] == Mark.Empty:
          b[row][col] = computer # set our move 
          let eval = minimax(b, depth + 1, false, max_depth) # run simulation
          b[row][col] = Mark.Empty # undo move

          max_eval = max(max_eval, eval)
    return maxEval
  else:
    var min_eval = Inf # set to ridiculusly high value so each score minimizes

    for row in 0..2:
      for col in 0..2:
        if b[row][col] == Mark.Empty:
          b[row][col] = player # set player move
          let eval = minimax(b, depth + 1, true, max_depth) # run simulation
          b[row][col] = Mark.Empty # undo move

          min_eval = min(min_eval, eval)
    return min_eval

proc getOptimalMove(b = board, maxDepth: int): tuple[row, col: int] =   
  var 
    bo = b
    maxscore: float = -Inf

  for row in 0..2:
    for col in 0..2:
      # if cell is filled (either an X or an O), then skip
      if bo[row][col] != Mark.Empty:
        continue
      
      # simulate move & find its score
      bo[row][col] = computer
      let thisscore = minimax(bo, isMaximizing = false, maxDepth = maxDepth)
      bo[row][col] = Mark.Empty
      
      # check if its better than other moves
      if thisscore > maxscore:
        maxscore = thisscore # if so, set the move's score as the max
        result = (row, col) # store the move

proc gameEnded(): bool =
  board.checkWin(computer) or board.checkWin(player) or board.checkDraw()

proc disableBoard() =
  let cells = document.getElementsByClassName("button-option")

  for cell in cells:
    cell.disabled = true

proc enableBoard() =
  ## enable all empty cells

  let cells = document.getElementsByClassName("button-option")

  for cell in cells:
    if cell.innerText == "":
      cell.disabled = false

proc restart() {.exportc.} =
  let cells = document.getElementsByClassName("button-option")

  for cell in cells:
    cell.innerText = ""
    cell.disabled = false
    cell.style.color = "rgb(209, 97, 255)"

  board = [[Empty, Empty, Empty], [Empty, Empty, Empty], [Empty, Empty, Empty]]

proc rowcolFromIdx(idx: int): (int, int) =
  if idx in 0..2: # values 0..2 are in first row
    (0, idx)
  elif idx in 3..5: # values 3..5 are in  second row
    (1, idx - 3) # subtract to make sure values are not above 2
                 # 0 < idx - x < 3
  else: # all other values are in the third row
    (2, idx - 6)

#proc idxFromRowcol(rowcol: tuple[row, col: int]): int =
#  if rowcol.row == 0: 
#    rowcol.col
#  elif rowcol.row == 1:
#    rowcol.col + 3
#  else:
#    rowcol.col + 6

proc updateInternalBoard(b: var Board = board) = 
  let cells = document.getElementsByClassName("button-option")

  for idx in 0..8: 
    let (row, col) = rowcolFromIdx(idx)

    case $cells[idx].innerText
    of "X":
      board[row][col] = Mark.X
    of "O":
      board[row][col] = Mark.O
    else:
      board[row][col] = Mark.Empty

proc displayBoard(b = board) = 
  let cells = document.getElementsByClassName("button-option")

  for idx in 0..8: 
    let (row, col) = rowcolFromIdx(idx)

    case b[row][col]
    of Mark.X:
      cells[idx].innerText = "X"
    of Mark.O:
      cells[idx].innerText = "O"
    else:
      cells[idx].innerText = ""

template setTimeout(ms: int, action: proc()) = 
  discard setTimeout(action, ms)

proc victoryHighlight(mark: Mark) = 
  let cells = document.getElementsByClassName("button-option")
  
  for cell in cells:
    if $cell.innerText == $mark or mark == Mark.Empty:
      if mark == Mark.O:
        cell.style.color = "cyan"
      elif mark == Mark.X:
        cell.style.color = "red"
      else:
        cell.style.color = "#C8C8C8" # grey
      
proc gameEnd() =
  if gameEnded():
    disableBoard()

    if board.checkWin(player):
      startConfetti(2000, minConfetti, maxConfetti)
      victoryHighlight(player)
      echo "You have won!"
    elif board.checkWin(computer):
      startConfetti(2000, minConfetti, maxConfetti) 
      victoryHighlight(computer)
      echo "The AI has won!"
    else:
      startConfetti(500, 0, 15)
      victoryHighlight(Mark.Empty) 
      echo "The game has ended in a draw!"

#proc bestMove() {.exportc.} = 
#  let 
#    move = getOptimalMove(maxDepth=9)
#    cells = document.getElementsByClassName("button-option")
#
#  cells[move.idxFromRowcol()].click()

let cells = document.getElementsByClassName("button-option")

for cell in cells:
  cell.addEventListener("click") do (ev: Event):
    if ev.target.innerText != "": return # if cell is filled, return

    let max_depth = parseInt($document.getElementById("depth").value)
    
    disableBoard() # lock board when player has made move

    ev.target.innerText = cstring $player
    updateInternalBoard()
    echo board

    ev.target.disabled = true # set button as disabled after move

    setTimeout(1) do ():
      if gameEnded(): return # make sure ai doesnt move after game is done
      let move = getOptimalMove(maxDepth = max_depth)

      board[move.row][move.col] = computer
      displayBoard(board)

      echo board

      enableBoard() # when the ai finishes playing, unlock the board

      gameEnd() # check if game ended after ai move

    gameEnd() # check if game ended after human move
