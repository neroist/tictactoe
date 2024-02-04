# tictactoe
Play Tic Tac Toe against minimax ai, built with [Nim](https://nim-lang.org/).



## Directories

### `terminal/`

[`terminal/`](./terminal/) is the terminal/text version of Tic Tac Toe, use `nim c -r tictactoe.nim` to compile and run it. May require `nimble install termui` in the future.

#### Files

* `tictactoe.nim`

    The terminal version of Tic Tac Toe? Not sure what to say here.

    Differences from web version:

    * you can choose whether or not to go first
    * you input moves via inputting the row and column number, not by clicking.

### `web/`

[`web/`](./web/) is the website version of Tic Tac Toe, which is released on Github Pages and can be accessed here: <https://neroist.github.io/tictactoe/>

#### Files

* `confetti.min.js`

    Javascript library to create a confetti effect. Its used for the confetti after an the end of a Tic Tac Toe match. I did not make it, I got it from [this](https://dev.to/official_fire/creating-a-confetti-effect-in-5-minutes-16h3) page, and it seems like someone named "Javier Sosa" created the original code or was involved in its creation. According to [their comment](https://dev.to/official_fire/creating-a-confetti-effect-in-5-minutes-16h3#comment-2553o), this was the original Stack Overflow question: <https://stackoverflow.com/questions/16322869/trying-to-create-a-confetti-effect-in-html5-how-do-i-get-a-different-fill-color>

* `confetti.nim`

    Small Nim bindings of the `confetti.min.js` file, used in `script.nim`. Feel free to take and use it for your own projects and such.

* `favicon.ico`

    Favicon of the website. Not sure why you wouldn't know but to explain: a favicon is the icon that appears at the top of a browser tab.

* `index.html`

    The html page for the website! Its what you see what you go to <https://neroist.github.io/tictactoe/>.

* `script.nim`

    Source code for the Javascript behind the website! The minimax algorithm and game mechanics & such are implemented here! This file is compiled into Javascript for use on the website. You can transpile it into js by running `nim js script.nim`; the resulting file will be `script.js`.

* `script.nim.cfg`

    Configuration file for the Nim compiler (when compiling `script.nim`). Sets `release` define flag and sets backend as `js`.

* `style.css`

    The styling for `index.html`.

###### Made with ❤️ with Nim
