type
  Mark* {.pure.} = enum
    Empty # 0
    X     # 1
    O     # 2

  Board* = array[3, array[3, Mark]]

proc checkWin*(b: Board, mark: Mark): bool = 
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

proc emptyCells*(b: Board): int = 
  ## returns amount of empty cells in the board
  
  for row in b:
    for mark in row:
      if mark == Mark.Empty:
        inc result  

proc checkDraw*(b: Board): bool =
  ## checks if all cells are filled
  
  emptyCells(b) == 0

proc minimax*(b: Board, computer, player: Mark, depth: int = 0, isMaximizing: bool = true, maxDepth: int): float = 
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
          let eval = minimax(b, computer, player, depth + 1, false, max_depth) # run simulation
          b[row][col] = Mark.Empty # undo move

          max_eval = max(max_eval, eval)
    return maxEval
  else:
    var min_eval = Inf # set to ridiculusly high value so each score minimizes

    for row in 0..2:
      for col in 0..2:
        if b[row][col] == Mark.Empty:
          b[row][col] = player # set player move
          let eval = minimax(b, computer, player, depth + 1, true, max_depth) # run simulation
          b[row][col] = Mark.Empty # undo move

          min_eval = min(min_eval, eval)
    return min_eval

proc getOptimalMove*(b: Board, computer, player: Mark, maxDepth: int): tuple[row, col: int] =   
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
      let thisscore = minimax(bo, computer, player, isMaximizing = false, maxDepth = maxDepth)
      bo[row][col] = Mark.Empty
      
      # check if its better than other moves
      if thisscore > maxscore:
        maxscore = thisscore # if so, set the move's score as the max
        result = (row, col) # store the move

proc gameEnded*(b: Board): bool =
  b.checkWin(Mark.X) or b.checkWin(Mark.O) or b.checkDraw()
