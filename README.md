# Tic Tac Toe
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

It contains 3 directories:

* `imgs/`, the image~~s~~ & favicon used in the website are kept here
* `js/`, the javascript used in the website is contained in here
* `styles/`, the css styling used by the website is here

#### `imgs/`

* `favicon.ico`

    Favicon of the website. Not sure why you wouldn't know but to explain: a favicon is the icon that appears at the top of a browser tab.

#### `js/`

* `confetti.min.js`

    Javascript library to create a confetti effect. Its used for the confetti after an the end of a Tic Tac Toe match. I did not make it, I got it from [this](https://dev.to/official_fire/creating-a-confetti-effect-in-5-minutes-16h3) page, and it seems like someone named "Javier Sosa" created the original code or was involved in its creation. According to [their comment](https://dev.to/official_fire/creating-a-confetti-effect-in-5-minutes-16h3#comment-2553o), this was the original Stack Overflow question: <https://stackoverflow.com/questions/16322869/trying-to-create-a-confetti-effect-in-html5-how-do-i-get-a-different-fill-color>

`script.js`/`script.min.js` is also kept here, when generated. See the `gh-pages` branch, [this](https://github.com/neroist/tictactoe/tree/gh-pages/js) directory.

#### `styles/`

* `style.css`

    The styling for `index.html`.

* `normalize.min.css`

    Stylesheet to make browsers render all elements more consistently.

#### Other files

Other files not kept in a subdirectory.

* `confetti.nim`

    Small Nim bindings of the `confetti.min.js` file, used in `script.nim`. Feel free to take and use it for your own projects and such.

* `index.html`

    The html page for the website! Its what you see what you go to <https://neroist.github.io/tictactoe/>.

* `script.nim`

    Source code for the Javascript behind the website! The minimax algorithm and game mechanics & such are implemented here! This file is compiled into Javascript for use on the website. You can transpile it into js by running `nim js script.nim`; the resulting file will be `script.js`.

* `script.nim.cfg`

    Configuration file for the Nim compiler (when compiling `script.nim`). Sets `release` define flag and sets backend as `js`.

## Building

Building & compiling this project requires Nim. You can download it here: <https://nim-lang.org/install.html> OR using [choosenim](https://github.com/dom96/choosenim).

### Terminal

For `terminal/tictactoe.nim`, just compiling it and running it with `nim c -r tictactoe.nim` is good enough. This compiles the code to an executable then runs it. Make sure you're in the `terminal/` directory when running that command.

### Web

For `web/` you need just to **transpile the code to JS**, then **visit `index.html`**. You can transpile the JS by running `nim js script.nim` in your terminal. This will result in the creation of a new file named `script.js`, which `index.html` uses. Then just open `index.html` file in a browser and you're done!

## Attribution

### Favicon

![`favicon.ico`](./web/imgs/favicon.ico)

[`favicon.ico`](./web/imgs/favicon.ico) (as shown above) is from uxwing.com, and can be found [here](https://uxwing.com/tic-tac-toe-icon/)

###### Made with ❤️ with Nim
