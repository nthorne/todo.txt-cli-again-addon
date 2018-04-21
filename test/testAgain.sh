#!/usr/bin/env bash

# vim: filetype=sh

TEST_FAILS=0
TEST_NAME=`basename $0`
TEST_LOCATION=$(cd `dirname $0`; pwd)
source $TEST_LOCATION/../againHelpers.sh

function usage()
{
  cat <<Usage_Heredoc
Usage: $(basename $0) [OPTIONS]

A simple test for the again todo.txt add-on

Where valid OPTIONS are:
  -h, --help  display usage

Usage_Heredoc
}

function parse_options()
{
  while (($#))
  do
    case $1 in
      -h|--help)
        usage
        exit 0
        ;;
      *)
        error "Unknown option: $1. Try $(basename $0) -h for options."
        ;;
    esac

    shift
  done
}

function setup_environment()
{
  # Use our sample file for the test
  export TODO_FILE="$TEST_LOCATION/sample.txt"
  test -f $TODO_FILE || error "$TODO_FILE: no such file"

  # Make the add-on call the call validation function, which
  # we export to any subshells..
  export TODO_FULL_SH=validate_call
  export -f validate_call

  # FreeBSD and NetBSD have mitigated the ShellShock vulnerability by requiring
  # an extra argument when scripts wish to call functions exported in the
  # environment. The GNU version of bash hasn't done that yet. So first try with
  # the new option, and fallback on calling bash without it.
  bash --import-functions -c exit 1>/dev/null 2>/dev/null
  if [ 0 -eq $? ]
  then
    AGAIN="bash --import-functions $TEST_LOCATION/../again again"
  else
    AGAIN="bash $TEST_LOCATION/../again again"
  fi
}


# For any call made to this function, there should be an item
# in the EXPECT list that matches $@. If not, the VALIDATION_FAIL
# variable is incremented, and an error message is displayed.
function validate_call()
{
  local array=( `echo $TEST_EXPECT` )
  #echo "Unpacked $TEST_EXPECT into ${#array[@]} items.."
  #echo
  if [[ 0 != ${#array[@]} ]]
  then
    # Extract the first item from the array..
    expected=${array[0]}
    # .. and convert any underscore into spaces. This is a bit
    # ugly, but it allows us to pass an array via an exported variable..
    expected=${expected//_/ }

    if [[ $expected == $@ ]]
    then
      #echo "EQ"
      :
    else
      TEST_FAILS=$(($TEST_FAILS + 1))
      echo "FAIL $TEST_FAILS: EXP($expected) NEQ ACT($@)"
    fi

    # Trim away the first item from the list
    trimmed=${array[@]:1}
    #echo "Trimmed array to ${trimmed[@]}"
    export TEST_EXPECT=`echo ${trimmed[@]}`
  else
    TEST_FAILS=$(($TEST_FAILS + 1))
    echo "FAIL $TEST_FAILS: UNEXPECTED: $@"
  fi

  export TEST_FAILS
  #echo "-> $TEST_FAILS"

  return $TEST_FAILS
}


# The test suite
function test_line_without_creation_date()
{
  expected=("command_do_1" "command_add_This_is_the_first_line")
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 1
  TEST_FAILS=$(($TEST_FAILS + $?))

  expected=("command_do_1" "command_add_This_is_the_first_line")
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 1 10
  TEST_FAILS=$(($TEST_FAILS + $?))

  expected=("command_do_1" "command_add_This_is_the_first_line")
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 1 +10
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_line_with_creation_date()
{
  expected=("command_do_2" "command_add_`date +%F`_This_is_the_second_line")
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 2
  TEST_FAILS=$(($TEST_FAILS + $?))

  expected=("command_do_2" "command_add_`date +%F`_This_is_the_second_line")
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 2 5
  TEST_FAILS=$(($TEST_FAILS + $?))

  expected=("command_do_2" "command_add_`date +%F`_This_is_the_second_line")
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 2 +10
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_line_with_creation_date_and_due_date()
{
  expected=("command_do_3" "command_add_`date +%F`_This_is_the_third_line_due:`date +%F`")

  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 3
  TEST_FAILS=$(($TEST_FAILS + $?))

  if [[ "GNU" == $DATE_VERSION ]]
  then
    expected=("command_do_3" "command_add_`date +%F`_This_is_the_third_line_due:`date -d '5 days' +%F`")
  else
    expected=("command_do_3" "command_add_`date +%F`_This_is_the_third_line_due:`date -j -v+5d +%F`")
  fi
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 3 5
  TEST_FAILS=$(($TEST_FAILS + $?))

  if [[ "GNU" == $DATE_VERSION ]]
  then
    expected=("command_do_3" "command_add_`date +%F`_This_is_the_third_line_due:`date -d '2013-02-02 +10 days' +%F`")
  else
    expected=("command_do_3" "command_add_`date +%F`_This_is_the_third_line_due:`date -j -v+10d -f %F 2013-02-02 +%F`")
  fi

  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 3 +10
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_line_with_creation_date_and_due_date_and_deferral_date()
{
  expected=("command_do_4" "command_add_`date +%F`_This_is_the_fourth_line_due:`date +%F`_t:`date +%F`")
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 4
  TEST_FAILS=$(($TEST_FAILS + $?))

  if [[ "GNU" == $DATE_VERSION ]]
  then
    expected=("command_do_4" "command_add_`date +%F`_This_is_the_fourth_line_due:`date -d '5 days' +%F`_t:`date -d '5 days' +%F`")
  else
    expected=("command_do_4" "command_add_`date +%F`_This_is_the_fourth_line_due:`date -j -v+5d +%F`_t:`date -j -v+5d +%F`")
  fi
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 4 5
  TEST_FAILS=$(($TEST_FAILS + $?))

  if [[ "GNU" == $DATE_VERSION ]]
  then
    expected=("command_do_4" "command_add_`date +%F`_This_is_the_fourth_line_due:`date -d '2013-03-03 +10 days' +%F`_t:`date -d '2013-02-02 +10 days' +%F`")
  else
    expected=("command_do_4" "command_add_`date +%F`_This_is_the_fourth_line_due:`date -j -v+10d -f %F 2013-03-03 +%F`_t:`date -j -v+10d -f %F 2013-02-02 +%F`")
  fi
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 4 +10
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_line_with_creation_date_and_deferral_date()
{
  expected=("command_do_5" "command_add_`date +%F`_This_is_the_fifth_line_t:`date +%F`")
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 5
  TEST_FAILS=$(($TEST_FAILS + $?))

  if [[ "GNU" == $DATE_VERSION ]]
  then
    expected=("command_do_5" "command_add_`date +%F`_This_is_the_fifth_line_t:`date -d '5 days' +%F`")
  else
    expected=("command_do_5" "command_add_`date +%F`_This_is_the_fifth_line_t:`date -v+5d +%F`")
  fi
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 5 5
  TEST_FAILS=$(($TEST_FAILS + $?))

  if [[ "GNU" == $DATE_VERSION ]]
  then
    expected=("command_do_5" "command_add_`date +%F`_This_is_the_fifth_line_t:`date -d '2013-04-04 +10 days' +%F`")
  else
    expected=("command_do_5" "command_add_`date +%F`_This_is_the_fifth_line_t:`date -j -v+10d -f %F 2013-04-04 +%F`")
  fi
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 5 +10
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_line_with_creation_date_and_prio()
{
  expected=("command_do_8" "command_add_(A)_`date +%F`_This_is_the_eighth_line")
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 8
  TEST_FAILS=$(($TEST_FAILS + $?))

  expected=("command_do_8" "command_add_(A)_`date +%F`_This_is_the_eighth_line")
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 8 5
  TEST_FAILS=$(($TEST_FAILS + $?))

  expected=("command_do_8" "command_add_(A)_`date +%F`_This_is_the_eighth_line")
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 8 +10
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_nonexisting_line()
{
  $AGAIN 42 2>/dev/null
  EXIT=$?
  if [[ ! $EXIT -eq 1 ]]
  then
    TEST_FAILS=$((TEST_FAILS + 1))
    echo "FAIL $TEST_FAILS: EXP EXIT(1) ACT EXIT($EXIT)"
  fi
}

function test_line_with_again_tag()
{
  if [[ "GNU" == $DATE_VERSION ]]
  then
    expected=("command_do_6" "command_add_`date +%F`_This_is_the_sixth_line_due:`date -d '5 days' +%F`_t:`date -d '5 days' +%F`_again:5")
  else
    expected=("command_do_6" "command_add_`date +%F`_This_is_the_sixth_line_due:`date -j -v+5d +%F`_t:`date -j -v+5d +%F`_again:5")
  fi
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 6
  TEST_FAILS=$(($TEST_FAILS + $?))

  if [[ "GNU" == $DATE_VERSION ]]
  then
    expected=("command_do_7" "command_add_`date +%F`_This_is_the_seventh_line_due:`date -d '2013-03-03 +10 days' +%F`_t:`date -d '2013-02-02 +10 days' +%F`_again:+10")
  else
    expected=("command_do_7" "command_add_`date +%F`_This_is_the_seventh_line_due:`date -j -v+10d -f %F 2013-03-03 +%F`_t:`date -j -v+10d -f %F 2013-02-02 +%F`_again:+10")
  fi
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 7
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_command_line_overrides_again_tag()
{
  TASK=6
  expected=("command_do_6" "command_add_`date +%F`_This_is_the_sixth_line_due:2013-03-20_t:2013-02-19_again:5")
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN $TASK +17
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_day_stepping()
{
  TASK=9
  expected=("command_do_$TASK" "command_add_Line_${TASK}_due:2015-08-22")
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN $TASK +7d
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_week_stepping()
{
  TASK=9
  expected=("command_do_$TASK" "command_add_Line_${TASK}_due:2015-09-05")
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN $TASK +3w
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_month_stepping()
{
  TASK=9
  expected=("command_do_$TASK" "command_add_Line_${TASK}_due:2015-11-15")
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN $TASK +3m
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_year_stepping()
{
  TASK=9
  expected=("command_do_$TASK" "command_add_Line_${TASK}_due:2027-08-15")
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN $TASK +12y
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_again_as_do()
{
  # First, test setting the TODO_NO_AGAIN_IF_NOT_TAGGED flag; if this is done,
  # line number one, which does not contain an again tag should not be added..
  export TODO_NO_AGAIN_IF_NOT_TAGGED=1
  TASK=1
  expected=("command_do_$TASK")
  TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN $TASK +17
  TEST_FAILS=$(($TEST_FAILS + $?))

  # Then, we try running again on task number 6, which does have an again tag;
  # this time, the task should be added..
  TASK=6
  expected=("command_do_6" "command_add_`date +%F`_This_is_the_sixth_line_due:2013-03-20_t:2013-02-19_again:5")
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN $TASK +17
  TEST_FAILS=$(($TEST_FAILS + $?))
  unset TODO_NO_AGAIN_IF_NOT_TAGGED

  # .. and finally, we re-run both test cases with the flag unset; now, both
  # of the tasks should be added..
  TASK=1
  expected=("command_do_$TASK" "command_add_This_is_the_first_line")
  TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN $TASK +17
  TEST_FAILS=$(($TEST_FAILS + $?))

  TASK=6
  expected=("command_do_6" "command_add_`date +%F`_This_is_the_sixth_line_due:2013-03-20_t:2013-02-19_again:5")
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN $TASK +17
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_line_with_again_tag_todo_adds_date()
{
  # Make sure that we drop dates as expected if todo.sh adds them..
  export TODOTXT_DATE_ON_ADD=1
  if [[ "GNU" == $DATE_VERSION ]]
  then
    expected=("command_do_10" "command_add_(A)_This_is_the_tenth_line_due:`date -d '2013-03-03 +10 days' +%F`_t:`date -d '2013-02-02 +10 days' +%F`_again:+10")
  else
    expected=("command_do_10" "command_add_(A)_This_is_the_tenth_line_due:`date -j -v+10d -f %F 2013-03-03 +%F`_t:`date -j -v+10d -f %F 2013-02-02 +%F`_again:+10")
  fi
  export TEST_EXPECT=`echo ${expected[@]}`
  $AGAIN 10
  TEST_FAILS=$(($TEST_FAILS + $?))
  export TODOTXT_DATE_ON_ADD=
}

parse_options "$@"
setup_environment
determine_date_version

test_line_without_creation_date
test_line_with_creation_date
test_line_with_creation_date_and_due_date
test_line_with_creation_date_and_due_date_and_deferral_date
test_line_with_creation_date_and_deferral_date
test_line_with_creation_date_and_prio
test_nonexisting_line
test_line_with_again_tag
test_command_line_overrides_again_tag
test_day_stepping
test_week_stepping
test_month_stepping
test_year_stepping
test_again_as_do
test_line_with_again_tag_todo_adds_date

[ $TEST_FAILS -eq 0 ] || error "Failures: $TEST_FAILS"
echo "All tests passed."
