[![Build Status](https://travis-ci.org/nthorne/todo.txt-cli-again-addon.svg?branch=master)](https://travis-ci.org/nthorne/todo.txt-cli-again-addon)

# Description

A [todo.txt](https://github.com/ginatrapani/todo.txt-cli) command line add-on
for marking a task as done, and then adding it again, adjusting due dates and
deferral dates if desired.

# Usage

    $ todo.sh again N
Mark item N as done, and then recreate it, with the creation date set as today's
date, and any existing due date set to today. Deferral date is not affected by
this operation. There is an exception if the item contains an `again:ADJUST`
tag; see below.

    $ todo.sh again N ADJUST
Mark item N as done, and then recreate it with the creation date set as today's
date, and any existing due date and deferral date set to ADJUST from today.

    $ todo.sh again N +ADJUST
Mark item N as done, and then recreate it with the creation date set as today's
date, and any existing due date and deferral date set to ADJUST from their
previous values.

You can also encode the adjustment interval in the task description with the
`again:` tag.

    $ todo.sh list 9
    (A) Do important things due:2001-01-01 t:2001-01-01 again:+5

    $ todo.sh again 9
    9 x 2001-01-03 (A) Do important things due:2001-01-01 t:2001-01-01 again:+5
    TODO: 9 marked as done.
    10 (A) Do important things due:2001-01-06 t:2001-01-06 again:+5
    TODO: 10 added.

But the again tag will be overriden by an adjustment provided on the command
line.

    $ todo.sh list 9
    (A) Do important things due:2001-01-01 t:2001-01-01 again:+5

    $ todo.sh again 9 +10
    9 x 2001-01-03 (A) Do important things due:2001-01-01 t:2001-01-01 again:+5
    TODO: 9 marked as done.
    10 (A) Do important things due:2001-01-11 t:2001-01-11 again:+5
    TODO: 10 added.

## Filter

In order to hide tasks whose threshold date are set to a future day, point the `TODO_TXT_FINAL_FILTER` environment variable to `againFilter.sh` in e.g. your `.bashrc`:

    # At an appropriate line in ~/.bashrc, assuming again is installed in ~/.todo.actions.d
    TODOTXT_FINAL_FILTER=${HOME}/.todo.actions.d/againFilter.sh

or, alternatively, add the following to `~/.todo/config`:

    export TODOTXT_FINAL_FILTER="${HOME}/.todo.actions.d/againFilter.sh"

## Adjustment Format

The ADJUST argument has the following format:

    (+)X(d|b|w|m|y)
- \+ = adjust dates relative to current values instead of today's date (optional)
- X = an integer indicating the magnitude of the adjustment (required)
- d, b, w, m, or y = adjust dates by days, business days (Mon-Fri), weeks, months, or years (optional, default is days if omitted)

Note that dates near the end of the month will drift from 31 to 30 (in months
with only 30 days) and eventually to 28 (if they are ever scheduled in February
of a common year, i.e. not a leap year).

    $ todo.sh list 12
    12 dates on this task will drift due:2014-10-31

    $ todo.sh again 12 +1m
    12 dates on this task will drift due:2014-11-30  ; only 30 days in November

    $ todo.sh again 12 +2m
    12 dates on this task will drift due:2015-01-30  ; drift is permanent

    $ todo.sh again 12 +1m
    12 dates on this task will drift due:2015-02-28  ; common year, only 28 days in February

    $ todo.sh again 12 +31d
    12 dates on this task will drift due:2015-03-31  ; adjust by days to keep task on the last day of the month

## Configuration

If the environment variable `TODO_NO_AGAIN_IF_NOT_TAGGED` is set, then again
will only re-add tasks that have an again tag in them, making the again command
a drop-in replacement for the `do` command for any tasks without the again tag.
See Examples for usage.

The environment variable `TODO_AGAIN_TAG` can be set to change the tag
which is used for the adjustment interval if present.

# Examples

Here are some examples that demonstrate how the again add-on works.

    $ date +%F
    2015-11-12

    $ todo.sh list
    1 learn something new
    2 change bathroom towels due:2015-11-15
    3 deposit paycheck due:2015-11-15
    4 replace smoke alarm batteries due:2015-10-20
    5 pay rent due:2015-12-03
    6 send flowers to Mom for her birthday due:2016-01-14 again:+1y

    $ todo.sh again 1
    1 x 2015-11-12 learn something new
    TODO: 1 marked as done.
    7 learn something new
    TODO: 7 added.

    $ TODO_NO_AGAIN_IF_NOT_TAGGED=1 todo.sh again 1
    1 x 2015-11-12 learn something new
    TODO: 1 marked as done.

    $ todo.sh again 2 14
    2 x 2015-11-12 change bathroom towels due:2015-11-15
    TODO: 2 marked as done.
    8 change bathroom towels due:2015-11-26
    TODO: 8 added.

    $ todo.sh again 3 +14
    3 x 2015-11-12 deposit paycheck due:2015-11-15
    TODO: 3 marked as done.
    9 deposit paycheck due:2015-11-29
    TODO: 9 added.

    $ todo.sh again 4 1y
    4 x 2015-11-12 replace smoke alarm batteries due:2015-10-20
    TODO: 4 marked as done.
    10 replace smoke alarm batteries due:2016-11-12
    TODO: 10 added.

    $ todo.sh again 5 +1m
    5 x 2015-11-12 pay rent due:2015-12-03
    TODO: 5 marked as done.
    11 pay rent due:2016-01-03
    TODO: 11 added.

    $ todo.sh again 6
    6 x 2015-11-12 send flowers to Mom for her birthday due:2016-01-14 again:+1y
    TODO: 6 marked as done.
    12 send flowers to Mom for her birthday due:2017-01-14 again:+1y
    TODO: 12 added.

    $ TODO_NO_AGAIN_IF_NOT_TAGGED=1 todo.sh again 6
    6 x 2015-11-12 send flowers to Mom for her birthday due:2016-01-14 again:+1y
    TODO: 6 marked as done.
    12 send flowers to Mom for her birthday due:2017-01-14 again:+1y
    TODO: 12 added.

# Licensing

This add-on is released under the GNU General Public License v.3.0. For further
details, refer to LICENSE.

# Attribution

This add-on is based on the
[repeat](https://github.com/drobertadams/todo.txt-cli-addons/tree/master/repeat)
add-on.

Thanks to the following developers for contributing features and fixes:

- ad1217 (Adam Goldsmith)
- cpence (Charles Pence)
- jbrc (James Blair)
- juzim (Julian Zimmermann)
- munkee (David Whitmarsh)
- tgdnt (Tiago Donato)
- owenh000 (Owen Heisler)
- adamschmalhofer (Adam Schmalhofer)
