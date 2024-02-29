import std/strutils
import std/terminal
import std/random

randomize()

type
  Piece = enum
    Blank
    Red
    Yellow

  Grid = array[7, array[6, Piece]]

var
  grid: Grid
  player1, player2: Piece

template red(str: string): string =
  "\e[31m" & str & "\e[0m"

template yellow(str: string): string =
  "\e[33m" & str & "\e[0m"

proc clear() =
  eraseScreen()
  setCursorPos(0, 0)

proc input(str: string): string = 
  ## python-like input function

  stdout.write str
  stdout.flushFile()
  stdin.readLine()

# ---

template gameEnded(g: Grid): bool =
  g.checkWin(player1) or g.checkWin(player2) or g.checkDraw()

proc emptyCells(g: Grid): int = 
  ## returns amount of empty cells in the grid
  
  for col in g:
    for cell in col:
      if cell == Blank:
        inc result 

proc colFilled(col: array[6, Piece]): bool = 
  result = true

  for piece in col:
    if piece == Blank:
      return false

proc makeMove(g: var Grid, piece: Piece, col: int): tuple[col, row: int] {.discardable.} = 
  result.col = col
  
  for cell_idx, cell in g[col]:
    if cell == Blank:
      result.row = cell_idx

  g[col][result.row] = piece

proc checkWin(g: Grid, piece: Piece): bool =
  if g.emptyCells > 47: # there needs to be atleast 7 moves before a win
    return false

  # row win
  for col in 0..2: # only check first 3 cols
    for row in 0..5: # check all rows
      if [g[col][row], g[col + 1][row], g[col + 2][row], g[col + 3][row]] == [piece, piece, piece, piece]:
        return true

  # column win
  for col in 0..6: # check all cols
    for row in 0..2: # check all rows
      if [g[col][row], g[col][row + 1], g[col][row + 2], g[col][row + 3]] == [piece, piece, piece, piece]:
        return true

  # main diagonal win
  for col in 0..3: # first 4 cols
    for row in 0..2: # first 3 rows
      if [g[col][row], g[col+1][row+1], g[col+2][row+2], g[col+3][row+3]] == [piece, piece, piece, piece]:
        return true

  # counter diagonal win
  for col in 0..3: # first 4 cols
    for row in 3..5: # last 3 rows
      if [g[col][row], g[col+1][row-1], g[col+2][row-2], g[col+3][row-3]] == [piece, piece, piece, piece]:
        return true

proc checkDraw(g: Grid): bool =
  ## checks if all cells are filled
  
  emptyCells(g) == 0

proc display(g: Grid, clear_screen: bool = false) =
  if clear_screen:
    clear()

  for row in 0..5:
    for col in 0..6:
      case g[col][row]

      of Blank:
        stdout.write " O "
      of Red:
        stdout.write red(" O ")
      of Yellow:
        stdout.write yellow(" O ")

      # stdout.write "col[", col, "][", row, "]"
    
    stdout.write "\n"

# uses alpha-beta pruning
proc minimax(g: Grid, depth: int = 0, isMaximizing: bool = true, maxDepth: int, alpha, beta: float): float = 
  var g = g

  if g.checkWin(player2):
    return 1 * float(g.emptyCells + 1) # multiply by number of empty cells to
                                       # incentivise quick wins, add by one
                                       # so we don't multiply by zero
  elif g.checkWin(player1):
    return -1 * float(g.emptyCells + 1)
  elif g.checkDraw() or depth == maxDepth:
    return 0

  if isMaximizing:
    var 
      maxEval = -Inf # set to ridiculusly low value as each score schould maximize
      alpha = alpha
      beta = beta

    for col in 0..6:
      let (col, row) = g.makeMove(player2, col) # set our move 
      var eval = minimax(g, depth + 1, false, max_depth, alpha, beta) # run simulation
      g[col][row] = Blank # undo move
      max_eval = max(max_eval, eval)
      if beta <= alpha:
        break
    return maxEval
  else:
    var min_eval = Inf # set to ridiculusly high value as each score schould maximize

    for col in 0..6:
      let (col, row) = g.makeMove(player1, col) # set player move
      var eval = minimax(g, depth + 1, true, max_depth, alpha, beta) # run simulation
      g[col][row] = Blank # undo move
      min_eval = min(min_eval, eval)
      if beta <= alpha:
        break
    return min_eval

proc getOptimalMove(g: Grid, maxDepth: int): int = 
  if g.emptyCells in 51..53:
    return rand(0..6)

  var 
    gr = g
    maxscore: float = -Inf

  for col in 0..6:
    if g[col].colFilled():
      # echo "col ", col,  " filled!"
      continue

    # simulate move & find its score
    let (co, row) = gr.makeMove(player2, col)
    let thisscore = minimax(gr, 0, false, maxDepth, -Inf, Inf)
    gr[co][row] = Blank
    
    # check if its better than other moves
    if thisscore > maxscore:
      maxscore = thisscore # if so, set the move's score as the max
      result = co # store the move

proc play() = 
  clear()

  echo "Welcome! \n"
  let playerstr = input("Who do you want to play as? ")
                    .strip()
                    .toLowerAscii()
  
  if playerstr in ["red", "r"]:
    player1 = Red
    player2 = Yellow
  elif playerstr in ["yellow", "y"]:
    player1 = Red
    player2 = Yellow
  else:
    echo "Invalid input"
    return

  while not grid.gameEnded():
    var col: int

    grid.display(clear_screen=true)
    echo "\n"

    col = parseInt input("What column do you want to play on [p1]? ")
    grid.makeMove(player1, col - 1)
    
    grid.display(clear_screen=true)
    echo "\n"

    if grid.gameEnded():
      break
    
    col = grid.getOptimalMove(5)
    grid.makeMove(player2, col)
    
    grid.display(clear_screen=true)
    echo "\n"

  grid.display(clear_screen=true)
  echo "\n"

  if grid.checkWin(player1):
    echo "Player 1 Won!"
  elif grid.checkWin(player2):
    echo "Player2 won!"
  else:
    echo "Draw!"

when isMainModule:
  play()
