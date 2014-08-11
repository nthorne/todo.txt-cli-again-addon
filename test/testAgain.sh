#!/usr/bin/env bash

# vim: filetype=sh

TEST_NAME=`basename $0`
TEST_LOCATION=$(cd `dirname $0`; pwd)


function usage()
{
  cat <<Usage_Heredoc
Usage: $(basename $0) [OPTIONS]

A simple test for the again todo.txt add-on

Where valid OPTIONS are:
  -h, --help  display usage

Usage_Heredoc
}

function error()
{
  echo "Error: $@" >&2
  exit 1
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


parse_options "$@"

setup_environment

# The test suite
function test_line_without_creation_date()
{
  expected=("command_do_1" "command_add_This_is_the_first_line")
  export TEST_EXPECT=`echo ${expected[@]}`
  $TEST_LOCATION/../again again 1
  TEST_FAILS=$(($TEST_FAILS + $?))

  expected=("command_do_1" "command_add_This_is_the_first_line")
  export TEST_EXPECT=`echo ${expected[@]}`
  $TEST_LOCATION/../again again 1 10
  TEST_FAILS=$(($TEST_FAILS + $?))

  expected=("command_do_1" "command_add_This_is_the_first_line")
  export TEST_EXPECT=`echo ${expected[@]}`
  $TEST_LOCATION/../again again 1 +10
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_line_with_creation_date()
{
  expected=("command_do_2" "command_add_`date +%Y-%m-%d`_This_is_the_second_line")
  export TEST_EXPECT=`echo ${expected[@]}`
  $TEST_LOCATION/../again again 2
  TEST_FAILS=$(($TEST_FAILS + $?))

  expected=("command_do_2" "command_add_`date +%Y-%m-%d`_This_is_the_second_line")
  export TEST_EXPECT=`echo ${expected[@]}`
  $TEST_LOCATION/../again again 2 5
  TEST_FAILS=$(($TEST_FAILS + $?))

  expected=("command_do_2" "command_add_`date +%Y-%m-%d`_This_is_the_second_line")
  export TEST_EXPECT=`echo ${expected[@]}`
  $TEST_LOCATION/../again again 2 +10
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_line_with_creation_date_and_due_date()
{
  expected=("command_do_3" "command_add_`date +%Y-%m-%d`_This_is_the_third_line_due:`date +%Y-%m-%d`")

  export TEST_EXPECT=`echo ${expected[@]}`
  $TEST_LOCATION/../again again 3
  TEST_FAILS=$(($TEST_FAILS + $?))

  if [[ "GNU" == $DATE_VERSION ]]
  then
    expected=("command_do_3" "command_add_`date +%Y-%m-%d`_This_is_the_third_line_due:`date -d '5 days' +%Y-%m-%d`")
  else
    expected=("command_do_3" "command_add_`date +%Y-%m-%d`_This_is_the_third_line_due:`date -j -v+5d +%Y-%m-%d`")
  fi
  export TEST_EXPECT=`echo ${expected[@]}`
  $TEST_LOCATION/../again again 3 5
  TEST_FAILS=$(($TEST_FAILS + $?))

  if [[ "GNU" == $DATE_VERSION ]]
  then
    expected=("command_do_3" "command_add_`date +%Y-%m-%d`_This_is_the_third_line_due:`date -d '2013-02-02 +10 days' +%Y-%m-%d`")
  else
    expected=("command_do_3" "command_add_`date +%Y-%m-%d`_This_is_the_third_line_due:`date -j -v+10d -f %Y-%m-%d 2013-02-02 +%Y-%m-%d`")
  fi

  export TEST_EXPECT=`echo ${expected[@]}`
  $TEST_LOCATION/../again again 3 +10
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_line_with_creation_date_and_due_date_and_deferral_date()
{
  expected=("command_do_4" "command_add_`date +%Y-%m-%d`_This_is_the_fourth_line_due:`date +%Y-%m-%d`_t:`date +%Y-%m-%d`")
  export TEST_EXPECT=`echo ${expected[@]}`
  $TEST_LOCATION/../again again 4
  TEST_FAILS=$(($TEST_FAILS + $?))

  if [[ "GNU" == $DATE_VERSION ]]
  then
    expected=("command_do_4" "command_add_`date +%Y-%m-%d`_This_is_the_fourth_line_due:`date -d '5 days' +%Y-%m-%d`_t:`date -d '5 days' +%Y-%m-%d`")
  else
    expected=("command_do_4" "command_add_`date +%Y-%m-%d`_This_is_the_fourth_line_due:`date -j -v+5d +%Y-%m-%d`_t:`date -j -v+5d +%Y-%m-%d`")
  fi
  export TEST_EXPECT=`echo ${expected[@]}`
  $TEST_LOCATION/../again again 4 5
  TEST_FAILS=$(($TEST_FAILS + $?))

  if [[ "GNU" == $DATE_VERSION ]]
  then
    expected=("command_do_4" "command_add_`date +%Y-%m-%d`_This_is_the_fourth_line_due:`date -d '2013-03-03 +10 days' +%Y-%m-%d`_t:`date -d '2013-02-02 +10 days' +%Y-%m-%d`")
  else
    expected=("command_do_4" "command_add_`date +%Y-%m-%d`_This_is_the_fourth_line_due:`date -j -v+10d -f %Y-%m-%d 2013-03-03 +%Y-%m-%d`_t:`date -j -v+10d -f %Y-%m-%d 2013-02-02 +%Y-%m-%d`")
  fi
  export TEST_EXPECT=`echo ${expected[@]}`
  $TEST_LOCATION/../again again 4 +10
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_line_with_creation_date_and_deferral_date()
{
  expected=("command_do_5" "command_add_`date +%Y-%m-%d`_This_is_the_fifth_line_t:`date +%Y-%m-%d`")
  export TEST_EXPECT=`echo ${expected[@]}`
  $TEST_LOCATION/../again again 5
  TEST_FAILS=$(($TEST_FAILS + $?))

  if [[ "GNU" == $DATE_VERSION ]]
  then
    expected=("command_do_5" "command_add_`date +%Y-%m-%d`_This_is_the_fifth_line_t:`date -d '5 days' +%Y-%m-%d`")
  else
    expected=("command_do_5" "command_add_`date +%Y-%m-%d`_This_is_the_fifth_line_t:`date -v+5d +%Y-%m-%d`")
  fi
  export TEST_EXPECT=`echo ${expected[@]}`
  $TEST_LOCATION/../again again 5 5
  TEST_FAILS=$(($TEST_FAILS + $?))

  if [[ "GNU" == $DATE_VERSION ]]
  then
    expected=("command_do_5" "command_add_`date +%Y-%m-%d`_This_is_the_fifth_line_t:`date -d '2013-04-04 +10 days' +%Y-%m-%d`")
  else
    expected=("command_do_5" "command_add_`date +%Y-%m-%d`_This_is_the_fifth_line_t:`date -j -v+10d -f %Y-%m-%d 2013-04-04 +%Y-%m-%d`")
  fi
  export TEST_EXPECT=`echo ${expected[@]}`
  $TEST_LOCATION/../again again 5 +10
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_line_with_creation_date_and_prio()
{
  expected=("command_do_6" "command_add_(A)_`date +%Y-%m-%d`_This_is_the_final_line")
  export TEST_EXPECT=`echo ${expected[@]}`
  $TEST_LOCATION/../again again 6
  TEST_FAILS=$(($TEST_FAILS + $?))

  expected=("command_do_6" "command_add_(A)_`date +%Y-%m-%d`_This_is_the_final_line")
  export TEST_EXPECT=`echo ${expected[@]}`
  $TEST_LOCATION/../again again 6 5
  TEST_FAILS=$(($TEST_FAILS + $?))

  expected=("command_do_6" "command_add_(A)_`date +%Y-%m-%d`_This_is_the_final_line")
  export TEST_EXPECT=`echo ${expected[@]}`
  $TEST_LOCATION/../again again 6 +10
  TEST_FAILS=$(($TEST_FAILS + $?))
}

function test_nonexisting_line()
{
  $TEST_LOCATION/../again again 42 2>/dev/null
  EXIT=$?
  if [[ ! $EXIT -eq 1 ]]
  then
    TEST_FAILS=$((TEST_FAILS + 1))
    echo "FAIL $TEST_FAILS: EXP EXIT(1) ACT EXIT($EXIT)"
  fi
}

function determine_date_version()
{
  date -v 1d 1>/dev/null 2>/dev/null
  if [[ 0 -eq $? ]]
  then
    DATE_VERSION="BSD"
  else
    DATE_VERSION="GNU"
  fi
}

determine_date_version

test_line_without_creation_date
test_line_with_creation_date
test_line_with_creation_date_and_due_date
test_line_with_creation_date_and_due_date_and_deferral_date
test_line_with_creation_date_and_deferral_date
test_line_with_creation_date_and_prio
test_nonexisting_line

[[ $TEST_FAILS -eq 0 ]] || error "Failures: $TEST_FAILS"
echo "All tests passed.."
