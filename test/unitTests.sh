#!/usr/bin/env bash

TEST_COUNT=0
TEST_FAILS=0
TEST_LOCATION=$(cd `dirname $0`; pwd)
source $TEST_LOCATION/../againHelpers.sh

function check_date_adjustment()
{
  TEST_COUNT=$((TEST_COUNT+1))
  ORIGINAL=$1
  ADJUST=$2
  adjust_date
  if [ "$3" != "$NEW_DATE" ]
  then
    echo "FAIL: EXP($3) NEQ ACT($NEW_DATE)"
    TEST_FAILS=$((TEST_FAILS+1))
  fi
}

determine_date_version

# some simple adjustments with implicit unit of days
check_date_adjustment 2015-11-20  5 2015-11-25
check_date_adjustment 2015-01-01 30 2015-01-31
check_date_adjustment 2015-01-01 31 2015-02-01 # month rollover
check_date_adjustment 2015-02-01 27 2015-02-28
check_date_adjustment 2015-02-01 28 2015-03-01
check_date_adjustment 2015-02-01 30 2015-03-03
check_date_adjustment 2016-02-28  1 2016-02-29 # leap year
check_date_adjustment 2015-03-10 30 2015-04-09

# adjustments with explicit unit of days
check_date_adjustment 2015-11-20  5d 2015-11-25
check_date_adjustment 2015-01-01 30d 2015-01-31
check_date_adjustment 2015-01-01 31d 2015-02-01 # month rollover
check_date_adjustment 2015-02-01 27d 2015-02-28
check_date_adjustment 2015-02-01 28d 2015-03-01
check_date_adjustment 2015-02-01 30d 2015-03-03
check_date_adjustment 2016-02-28  1d 2016-02-29 # leap year
check_date_adjustment 2016-02-29  1d 2016-03-01 # day adjustment does not get special handling
check_date_adjustment 2016-01-31 30d 2016-03-01
check_date_adjustment 2015-03-10 30d 2015-04-09

# adjustments for years
check_date_adjustment 2015-11-20 1y 2016-11-20
check_date_adjustment 2016-02-29 1y 2017-02-28 # leap year to common year; trim to same month
check_date_adjustment 2016-02-29 4y 2020-02-29 # leap year to leap year

# adjustments for months
check_date_adjustment 2015-08-19  1m 2015-09-19
check_date_adjustment 2015-12-19  1m 2016-01-19
check_date_adjustment 2016-02-29  1m 2016-03-29
check_date_adjustment 2015-03-31  6m 2015-09-30 # 30 days hath September
check_date_adjustment 2015-03-31  1m 2015-04-30 # April
check_date_adjustment 2015-03-31  3m 2015-06-30 # June
check_date_adjustment 2015-03-31  8m 2015-11-30 # and November
check_date_adjustment 2017-01-29  1m 2017-02-28 # common year
check_date_adjustment 2016-12-31  2m 2017-02-28
check_date_adjustment 2016-12-30  2m 2017-02-28
check_date_adjustment 2016-12-29  2m 2017-02-28
check_date_adjustment 2016-12-28  2m 2017-02-28
check_date_adjustment 2016-02-29 12m 2017-02-28 # leap year to common year
check_date_adjustment 2016-02-29 48m 2020-02-29 # leap year to leap year

# make sure adjust_date ignores the leading +
check_date_adjustment 2015-02-01 +30 2015-03-03
check_date_adjustment 2016-02-29 +1d 2016-03-01
check_date_adjustment 2015-11-20 +1y 2016-11-20
check_date_adjustment 2015-03-31 +8m 2015-11-30

[ $TEST_FAILS -eq 0 ] || error "Failures: $TEST_FAILS"
echo "$TEST_COUNT tests OK"
