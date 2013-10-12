# Description

A [todo.txt](https://github.com/ginatrapani/todo.txt-cli) command line add-on for marking a task as done, and then
adding it again, adjusting due dates and deferral dates if desired.

# Usage

    $ todo.sh again N
Mark item N as done, and then recreate it, with the creation date set
as todays date, and any existing due date set to today. Deferral date
is not affected by this operation.

    $ todo.sh again N DAYS
Mark item N as done, and then recreate it with the creation date set
as todays date, and any existing due date and deferral date set to
DAYS days from today.

    $ todo.sh again N +DAYS
Mark item N as done, and then recreate it with the creation date set
as todays date, and any existing due date and deferral date set to
DAYS days from their previous values.

# Licensing

This add-on is released under the GNU General Public License v.3
for further details, refer to LICENSE.

# Attribution

This add-on is based on the
[repeat](https://github.com/drobertadams/todo.txt-cli-addons/tree/master/repeat)
add-on.
