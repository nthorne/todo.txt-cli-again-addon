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

# tests for 'b' recurrence 
check_date_adjustment 2018-11-05  1b 2018-11-06 "1 business days Monday to Tuesday"
check_date_adjustment 2018-11-05  2b 2018-11-07 "2 business days Monday to Wednesday"
check_date_adjustment 2018-11-05  3b 2018-11-08 "3 business days Monday to Thursday"
check_date_adjustment 2018-11-05  4b 2018-11-09 "4 business days Monday to Friday"
check_date_adjustment 2018-11-05  5b 2018-11-12 "5 business days Monday to Monday"
check_date_adjustment 2018-11-05  6b 2018-11-13 "6 business days Monday to Tuesday"
check_date_adjustment 2018-11-05  7b 2018-11-14 "7 business days Monday to Wednesday"
check_date_adjustment 2018-11-05  8b 2018-11-15 "8 business days Monday to Thursday"
check_date_adjustment 2018-11-05  9b 2018-11-16 "9 business days Monday to Friday"
check_date_adjustment 2018-11-05 14b 2018-11-23 "14 business days Monday to Friday"
check_date_adjustment 2018-11-05 17b 2018-11-28 "17 business days Monday to Wednesday"
check_date_adjustment 2018-11-05 24b 2018-12-07 "24 business days Monday to Friday"

check_date_adjustment 2018-11-06  1b 2018-11-07 "1 business days Tuesday to Wednesday"
check_date_adjustment 2018-11-06  2b 2018-11-08 "2 business days Tuesday to Thursday"
check_date_adjustment 2018-11-06  3b 2018-11-09 "3 business days Tuesday to Friday"
check_date_adjustment 2018-11-06  4b 2018-11-12 "4 business days Tuesday to Monday"
check_date_adjustment 2018-11-06  5b 2018-11-13 "5 business days Tuesday to Tuesday"
check_date_adjustment 2018-11-06  6b 2018-11-14 "6 business days Tuesday to Wednesday"
check_date_adjustment 2018-11-06  7b 2018-11-15 "7 business days Tuesday to Thursday"
check_date_adjustment 2018-11-06  8b 2018-11-16 "8 business days Tuesday to Friday"
check_date_adjustment 2018-11-06  9b 2018-11-19 "9 business days Tuesday to Monday"
check_date_adjustment 2018-11-06 14b 2018-11-26 "14 business days Tuesday to Monday"
check_date_adjustment 2018-11-06 17b 2018-11-29 "17 business days Tuesday to Thursday"
check_date_adjustment 2018-11-06 24b 2018-12-10 "24 business days Tuesday to Monday"

check_date_adjustment 2018-11-07  1b 2018-11-08 "1 business days Wednesday to Thursday"
check_date_adjustment 2018-11-07  2b 2018-11-09 "2 business days Wednesday to Friday"
check_date_adjustment 2018-11-07  3b 2018-11-12 "3 business days Wednesday to Monday"
check_date_adjustment 2018-11-07  4b 2018-11-13 "4 business days Wednesday to Tuesday"
check_date_adjustment 2018-11-07  5b 2018-11-14 "5 business days Wednesday to Wednesday"
check_date_adjustment 2018-11-07  6b 2018-11-15 "6 business days Wednesday to Thursday"
check_date_adjustment 2018-11-07  7b 2018-11-16 "7 business days Wednesday to Friday"
check_date_adjustment 2018-11-07  8b 2018-11-19 "8 business days Wednesday to Monday"
check_date_adjustment 2018-11-07  9b 2018-11-20 "9 business days Wednesday to Tuesday"
check_date_adjustment 2018-11-07 14b 2018-11-27 "14 business days Wednesday to Tuesday"
check_date_adjustment 2018-11-07 17b 2018-11-30 "17 business days Wednesday to Friday"
check_date_adjustment 2018-11-07 24b 2018-12-11 "24 business days Wednesday to Tuesday"

check_date_adjustment 2018-11-08  1b 2018-11-09 "1 business days Thursday to Friday"
check_date_adjustment 2018-11-08  2b 2018-11-12 "2 business days Thursday to Monday"
check_date_adjustment 2018-11-08  3b 2018-11-13 "3 business days Thursday to Tuesday"
check_date_adjustment 2018-11-08  4b 2018-11-14 "4 business days Thursday to Wednesday"
check_date_adjustment 2018-11-08  5b 2018-11-15 "5 business days Thursday to Thursday"
check_date_adjustment 2018-11-08  6b 2018-11-16 "6 business days Thursday to Friday"
check_date_adjustment 2018-11-08  7b 2018-11-19 "7 business days Thursday to Monday"
check_date_adjustment 2018-11-08  8b 2018-11-20 "8 business days Thursday to Tuesday"
check_date_adjustment 2018-11-08  9b 2018-11-21 "9 business days Thursday to Wednesday"
check_date_adjustment 2018-11-08 14b 2018-11-28 "14 business days Thursday to Wednesday"
check_date_adjustment 2018-11-08 17b 2018-12-03 "17 business days Thursday to Monday"
check_date_adjustment 2018-11-08 24b 2018-12-12 "24 business days Thursday to Wednesday"

check_date_adjustment 2018-11-09  1b 2018-11-12 "1 business days Friday to Monday"
check_date_adjustment 2018-11-09  2b 2018-11-13 "2 business days Friday to Tuesday"
check_date_adjustment 2018-11-09  3b 2018-11-14 "3 business days Friday to Wednesday"
check_date_adjustment 2018-11-09  4b 2018-11-15 "4 business days Friday to Thursday"
check_date_adjustment 2018-11-09  5b 2018-11-16 "5 business days Friday to Friday"
check_date_adjustment 2018-11-09  6b 2018-11-19 "6 business days Friday to Monday"
check_date_adjustment 2018-11-09  7b 2018-11-20 "7 business days Friday to Tuesday"
check_date_adjustment 2018-11-09  8b 2018-11-21 "8 business days Friday to Wednesday"
check_date_adjustment 2018-11-09  9b 2018-11-22 "9 business days Friday to Thursday"
check_date_adjustment 2018-11-09 14b 2018-11-29 "14 business days Friday to Thursday"
check_date_adjustment 2018-11-09 17b 2018-12-04 "17 business days Friday to Tuesday"
check_date_adjustment 2018-11-09 24b 2018-12-13 "24 business days Friday to Thursday"

check_date_adjustment 2018-11-03 1b 2018-11-05 "1 business days Saturday to Monday"
check_date_adjustment 2018-11-03 3b 2018-11-07 "3 business days Saturday to Wednesday"
check_date_adjustment 2018-11-03 9b 2018-11-15 "9 business days Saturday to Thursday"
check_date_adjustment 2018-11-03 12b 2018-11-20 "12 business days Saturday to Tuesday"
check_date_adjustment 2018-11-03 17b 2018-11-27 "17 business days Saturday to Tuesday"
check_date_adjustment 2018-11-03 21b 2018-12-03 "21 business days Saturday to Monday"
check_date_adjustment 2018-11-03 25b 2018-12-07 "25 business days Saturday to Friday"
check_date_adjustment 2018-11-03 29b 2018-12-13 "29 business days Saturday to Thursday"

check_date_adjustment 2018-11-04 1b 2018-11-05 "1 business days Sunday to Monday"
check_date_adjustment 2018-11-04 3b 2018-11-07 "3 business days Sunday to Wednesday"
check_date_adjustment 2018-11-04 9b 2018-11-15 "9 business days Sunday to Thursday"
check_date_adjustment 2018-11-04 12b 2018-11-20 "12 business days Sunday to Tuesday"
check_date_adjustment 2018-11-04 17b 2018-11-27 "17 business days Sunday to Tuesday"
check_date_adjustment 2018-11-04 21b 2018-12-03 "21 business days Sunday to Monday"
check_date_adjustment 2018-11-04 25b 2018-12-07 "25 business days Sunday to Friday"
check_date_adjustment 2018-11-04 29b 2018-12-13 "29 business days Sunday to Thursday"

[ $TEST_FAILS -eq 0 ] || error "Failures: $TEST_FAILS"
echo "$TEST_COUNT tests OK"
