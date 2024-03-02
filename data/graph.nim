import std/sequtils
import std/json

import plotly
import chroma

var
  loss_rates, win_rates, draw_rates, time_taken: seq[float]
  wins, losses, draws: seq[int]

  depths: seq[int] = @[1, 2, 3, 4, 5, 6, 7, 8]

for obj in parseFile(currentSourcePath() & "/../data.json"):
  loss_rates.add obj["loss_rate"].getFloat()
  win_rates.add obj["win_rate"].getFloat()
  draw_rates.add obj["draw_rate"].getFloat()
  time_taken.add obj["time_taken"].getFloat()

  wins.add obj["wins"].getInt()
  losses.add obj["losses"].getInt()
  draws.add obj["draws"].getInt()

proc newLayout(y_axis: string): Layout =
  Layout(
    title: "Minimax Algorithm vs. Random Moves",
    width: 1200,
    height: 400,
    yaxis: Axis(title: y_axis),
    xaxis: Axis(title: "AI Max Depth"),
    autosize: false
  )

proc newTrace[T](ys: seq[T], name: string = ""): Trace[T] =
  var xs: seq[T]

  depths.apply(
    proc(num: int) = xs.add(num.T)
  )

  Trace[T](
    `type`: PlotType.Bar,
    name: name,
    xs: xs,
    ys: ys
  )
  
let
  dLossRate* = newTrace[float](loss_rates, "Loss Rate %")
  dWinRate* = newTrace[float](win_rates, "Win Rate %")
  dDrawRate* = newTrace[float](draw_rates, "Draw Rate %")
  dTimeTaken* = newTrace[float](time_taken, "Time Taken (in seconds)")

  dWins* = newTrace[int](wins, "Wins")
  dLosses* = newTrace[int](losses, "Losses")
  dDraws* = newTrace[int](draws, "Draws")

let 
  pLossRate* = Plot[float](layout: newLayout("Loss Rate %"), traces: @[dLossRate])
  pWinRate* = Plot[float](layout: newLayout("Win Rate %"), traces: @[dWinRate])
  pDrawRate* = Plot[float](layout: newLayout("Draw Rate %"), traces: @[dDrawRate])
  pTimeTaken* = Plot[float](layout: newLayout("Time Taken (in seconds)"), traces: @[dTimeTaken])
  
  pWins* = Plot[int](layout: newLayout("Wins"), traces: @[dWins])
  pLosses* = Plot[int](layout: newLayout("Losses"), traces: @[dLosses])
  pDraws* = Plot[int](layout: newLayout("Draws"), traces: @[dDraws])

# Combined Plot - Wins, Draws, Losses

block:
  let layout = newLayout("Wins, Draws, Losses")
  layout.yaxis.ty = AxisType.Log
  
  let plot = Plot[int](layout: layout, traces: @[dWins, dDraws, dLosses])
  plot.show()

# Combined Plot - Win Rate %, Draw Rate %, Loss Rate %

block:
  let layout = newLayout("Win Rate %, Draw Rate %, Loss Rate %")
  layout.yaxis.ty = AxisType.Log

  let traces = @[dWinRate, dDrawRate, dLossRate]

  let plot = Plot[float](layout: layout, traces: traces)

  plot.show()

# Single Plot - Time Taken

block:
  pTimeTaken.markerColor(@[Color(r: 0.89, g: 0.47, b: 0.76)])
            .show()
