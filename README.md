## git-edit-atom package
------------
Want to use Atom's handy `COMMIT_EDITMSG` syntax highlighting?
🙋

Tired of waiting on Atom to open a new window with the `--wait` option?
:hourglass: :sleeping:

Together with [sister Go package `git-commit-atom`](https://github.com/mmore500/git-commit-atom), this Atom package allows Git commit files to be conveniently edited in the current editor pane... avoiding the launch of another instance of Atom!
:star2: :smirk:

![A screenshot of git-edit-atom and git-commit-atom in action together](https://thumbs.gfycat.com/BaggyFreshBoaconstrictor-size_restricted.gif)

## Prerequisites
* Go package `git-commit-atom` (instructions on how to install [here](https://github.com/mmore500/git-commit-atom))

## Installation
Installation of the package can be performed via Atom's Settings pane or on the command line via the Atom Package Manager.
~~~bash
apm install git-edit-atom
~~~
See the [`git-commit-atom` repository](https://github.com/mmore500/git-commit-atom) for instructions on how to install the sister Go package.

## Implementation
This project has two components: a standalone Go script that acts as the editor called by Git during the commit process and the Atom package `git-edit-atom`.
When the standalone Go script is activated, it opens the `COMMIT_EDITMSG` file in the current Atom pane.
When that file is closed, Atom appends a "magic marker" (`## ATOM EDIT COMPLETE##`) to the end of the `COMMIT_EDITMSG` file.
The Go script, which is listening to the end of the `COMMIT_EDITMSG` file, recognizes the "magic marker" and terminates, ending the commit edit session.
In addition, the Go script listens for user input at the terminal.
The commit session can also be ended by entering `quit` or `done`.
(This functionality allows the standalone script to function in some capacity without the Atom package in place).
This approach is directly inspired by AJ Foster's "git-commit-atom.sh", [presented on his personal blog](https://aj-foster.com/2016/git-commit-atom/).
However, this project is implemented in Go and as an Atom package in hopes of gaining portability and reliability.
