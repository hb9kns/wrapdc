# Command line wrapper for `dc (1)`

This wrapper renders `dc` more usable as a command line calculator by:

- defining commonly used macros for more complex operations
- saving precision, top of stack, and registers 0 to 9 ("memories")
  from one invocation to the next

## Prerequisites

The POSIX conform program `dc` ("desktop calculator") and standard shell `sh`
must be installed and accessible through `$PATH`.

## Installation and Use

The wrapper script `wrapdc.sh` can be called directly (if executable) or by
invoking `sh wrapdc.sh` with optional arguments.

If arguments are given, they are interpreted as one line of commands,
which is executed, and then the script finishes.

If no arguments are given, the script enters a loop: read a line
of input from STDIN, execute it, and display the resulting top-of-stack.
The loop (and script) finishes, when `quit` or CTRL-D is entered.

All normal `dc` commands can be used, see the corresponding manual.
In particular, negative numbers must be entered with a leading `_`
(underscore) as minus sign, not a `-` (dash), because the latter is
indicating the command 'subtraction'.

The `dc` command `r` (exchanging the two topmost stack entries) is emulated
with some internal register operations, as it is a GNU extension and may not
always be available. This may render complex operations somewhat slower.

In addition to the `quit` command, the following pseudocommands are handled
directly by the wrapper:

- `list` displays a list of predefined macros
- `verb` activates verbose mode, which displays before each execution of
  input line the input from the status file as well as the input line with
  expanded macro definitions
- `noverb` deactivates verbose mode

All pseudocommands must be entered at the beginning of a line, and all
subsequent input on this line will be ignored.

Verbose mode can also be activated with the command line option `-v` which
may be useful in case of direct input with further command line arguments.

## Examples

(We assume `wrapdc.sh` is accessible via `$PATH` in what follows.)

	$ wrapdc.sh 5k 2v # precision 5, 2 on stack, calculate square root
	1.41421
	$ wrapdc.sh 3 7/ # 3, divide by 7 (precision was saved from last run)
	.42857
	$ wrapdc.sh list # display macros (and top of stack before finishing)
	: %t # percent part: X:=100*(X/Y), Y kept
	: % # percentage: X:=X*Y/100, Y kept
	: rem # remainder: X:=Y%X (instead of normal % command)
	: sto\(.\) # sto.: store with copying (i.e keep value on stack)
	: fact # factorial: X:=X!
	: neg # negate: X:=-X
	: r # revert: X:=Y, Y:=X (r is a GNU only extension)
	.42857
	$ wrapdc.sh 42fact sto1 # calculate 42! (factorial) and store in '1'
	1405006117752879898543142606244511569936384000000000
	$ wrapdc.sh 2k234 7%+ # precision 2, add 7% to 234
	250.38
	$ wrapdc.sh 234r%t+ # which is how many % of 234?
	107.00
	$ wrapdc.sh l1 40fact/ # divide memory '1' by the factorial of 40
	1722.0
	$ wrapdc.sh 41 42* # which of course is 42!/40!=41*42
	1722

Note: the last example only works if there is no file beginning with '42'
in the current directory, otherwise the shell will expand its name before
passing on the argument to the wrapper script. In this case, you should
escape the `*` or put the arguments in apostrophes `'41 42*'` or simply
start the wrapper without arguments, and do the calculations in its internal
command loop.

## Macros

Macros can be easily added to the script, if you know `sed` syntax.
They are defined in the shell variable `mcrs.` where each one should be
written on a separate line with comma `,` as pattern delimiters, followed
by `;#` and a comment explaining its use.
This allows the `list` pseudocommand to display them together with the
comment. _Do not prepend any white space to the definition, otherwise
it will not be displayed by `list`!_

Please note that the macro expansion is global and "stupid" -- you should
therefore define the longer commands first, and single character commands
only at the very end. Otherwise, e.g the `rem` command would first have its
`r` expanded as the "revert" command, therefore `rem` expansion would fail.

## Bugs

For the time being, results longer than 80 characters are not displayed
correctly, as the logics treating `dc` continuation lines is missing.
Internal results are not affected by this (but also results stored in
registers/"memories" 0 to 9).

---

_(2016-April, Y.Bonetti)_
