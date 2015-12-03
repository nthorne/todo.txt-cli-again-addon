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
    echo "FAIL: EXP($3) NEQ ACT($NEW_DATE) $4"
    TEST_FAILS=$((TEST_FAILS+1))
  fi
}

determine_date_version

# some simple adjustments with implicit unit of days
check_date_adjustment 2015-11-20  5 2015-11-25 "5 (days)"
check_date_adjustment 2015-01-01 30 2015-01-31 "30 (days)"
check_date_adjustment 2015-01-01 31 2015-02-01 "month rollover (days)"
check_date_adjustment 2015-02-01 28 2015-03-01 "28 (days) Feb to Mar"
check_date_adjustment 2015-02-01 30 2015-03-03 "30 (days) Feb to Mar"
check_date_adjustment 2016-02-28  1 2016-02-29 "1 (day) leap year"

# adjustments with explicit unit of days
check_date_adjustment 2015-11-20  5d 2015-11-25 "5 days"
check_date_adjustment 2015-01-01 30d 2015-01-31 "30 days"
check_date_adjustment 2015-01-01 31d 2015-02-01 "month rollover days"
check_date_adjustment 2015-02-01 28d 2015-03-01 "28 days Feb to Mar"
check_date_adjustment 2015-02-01 30d 2015-03-03 "30 days Feb to Mar"
check_date_adjustment 2016-02-28  1d 2016-02-29 "1 day leap year"
check_date_adjustment 2016-02-29  1d 2016-03-01 "1 day leap year rollover"
check_date_adjustment 2016-01-31 30d 2016-03-01 "30 days skip Feb"

# adjustments for years
check_date_adjustment 2015-11-20 1y 2016-11-20 "1 year"
check_date_adjustment 2016-02-29 1y 2017-02-28 "1 year leap year to common year"
check_date_adjustment 2016-02-29 4y 2020-02-29 "4 years leap year to leap year"

# adjustments for months
check_date_adjustment 2015-08-19  1m 2015-09-19 "1 month"
check_date_adjustment 2015-12-19  1m 2016-01-19 "1 month year rollover"
check_date_adjustment 2016-02-29  1m 2016-03-29 "1 month from leap day"
check_date_adjustment 2015-03-31  6m 2015-09-30 "September drift"
check_date_adjustment 2015-03-31  1m 2015-04-30 "April drift"
check_date_adjustment 2015-03-31  3m 2015-06-30 "June drift"
check_date_adjustment 2015-03-31  8m 2015-11-30 "November drift"
check_date_adjustment 2017-01-29  1m 2017-02-28 "Feb drift common year"
check_date_adjustment 2016-12-31  2m 2017-02-28 "Feb drift from 31 common year"
check_date_adjustment 2016-12-30  2m 2017-02-28 "Feb drift from 30 common year"
check_date_adjustment 2016-12-29  2m 2017-02-28 "Feb drift from 29 common year"
check_date_adjustment 2016-12-28  2m 2017-02-28 "no Feb drift from 28"
check_date_adjustment 2015-12-30  2m 2016-02-29 "Feb drift from 30 leap year"
check_date_adjustment 2016-02-29 12m 2017-02-28 "12 months leap year to common year"
check_date_adjustment 2016-02-29 48m 2020-02-29 "48 months leap year to leap year"

# make sure adjust_date ignores the leading +
check_date_adjustment 2015-02-01 +30 2015-03-03 "leading plus 30 (days)"
check_date_adjustment 2016-02-29 +1d 2016-03-01 "leading plus 1 day"
check_date_adjustment 2015-11-20 +1y 2016-11-20 "leading plus 1 year"
check_date_adjustment 2015-03-31 +8m 2015-11-30 "leading plus 8 months"

[ $TEST_FAILS -eq 0 ] || error "Failures: $TEST_FAILS"
echo "$TEST_COUNT tests OK"
