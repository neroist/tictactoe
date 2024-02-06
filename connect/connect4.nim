import std/strutils
import std/terminal

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

proc makeMove(g: var Grid, piece: Piece, col: int): tuple[row, col: int] {.discardable.} = 
  result.col = col
  
  for cell_idx, cell in g[col]:
    if cell == Blank:
      result.row = cell_idx

  g[col][result.row] = piece

proc checkWin(g: Grid, piece: Piece): bool =
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
    
    col = parseInt input("What column do you want to play on [p2]? ")
    grid.makeMove(player2, col - 1)
    
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

grid.makeMove(Red, 0)
grid.makeMove(Red, 0)
grid.makeMove(Red, 0)
grid.makeMove(Yellow, 0)
grid.makeMove(Yellow, 1)
grid.makeMove(Yellow, 1)
grid.makeMove(Yellow, 1)
grid.makeMove(Yellow, 2)
grid.makeMove(Yellow, 2)
grid.makeMove(Yellow, 3)

grid.display()
echo grid.checkWin(Yellow)

# when isMainModule:
#   play()
