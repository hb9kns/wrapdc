# command line wrapper for `dc (1)`

This wrapper renders `dc` more usable as a command line calculator by:

- defining commonly used macros for more complex operations
- saving precision, top of stack, and registers 0 to 9 ("memories")
  from one invocation to the next

## prerequisites

The POSIX conform program `dc` or "desktop calculator" and standard shell `sh`
must be installed and accessible through `$PATH`.

## installation and use

The wrapper script `wdc.sh` can be called directly (if executable) or by
invoking `sh wdc.sh` with optional arguments.

If arguments are passed on, they are interpreted as one line of commands,
which is executed, and then the script finishes.

If no arguments are passed to the script, it enters a loop of reading a line
of input from STDIN, executing it, and display of resulting top of stack.
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

Verbose mode can also be activated with the command line option `-v` which
may be useful in case of direct input with further command line arguments.

## examples

	$ sh wdc.sh 5k 2v # precision 5, 2 on stack, calculate square root
	1.41421
	$ sh wdc.sh 3 7/ # 3, divide by 7 (precision was saved from last run)
	$ sh wdc.sh list # display macros (and top of stack before finishing)
	: %t # percent part: X:=100*(X/Y), Y kept
	: % # percentage: X:=X*Y/100, Y kept
	: rem # remainder: X:=Y%X (instead of normal % command)
	: sto\(.\) # sto.: store with copying (i.e keep value on stack)
	: fact # factorial: X:=X!
	: neg # negate: X:=-X
	: r # revert: X:=Y, Y:=X (r is a GNU only extension)
	.42857

