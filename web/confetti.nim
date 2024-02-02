proc startConfetti*(timeout: cint = 0, min: cint = 0, max: cint = 0) {.importjs: "confetti.start(@)".}
proc stopConfetti*() {.importjs: "confetti.stop()".}
proc toggleConfetti*() {.importjs: "confetti.toggle()".}
proc pauseConfetti*() {.importjs: "confetti.pause()".}
proc resumeConfetti*() {.importjs: "confetti.resume()".}
proc toggleConfettiPause*() {.importjs: "confetti.togglePause()".}
proc isConfettiPaused*(): bool {.importjs: "confetti.isPaused()".}
proc removeConfetti*() {.importjs: "confetti.remove()".}
proc isConfettiRunning*(): bool {.importjs: "confetti.isRunning()".}