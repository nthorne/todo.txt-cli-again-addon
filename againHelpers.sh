#!/usr/bin/env bash

#Copyright (C) 2013 Niklas Thorne.
#
#This file is part of again.
#
#again is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#again is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with again.  If not, see <http://www.gnu.org/licenses/>.

readonly DATE_FORMAT="%F" # %F == %Y-%m-%d for BSD and GNU

# Adjust $ORIGINAL by $ADJUST, store in $NEW_DATE
function adjust_date()
{
  ADJUST_NUM=`expr "$ADJUST" : '+*\([1-9][0-9]*\)'`
  ADJUST_UNIT=`expr "$ADJUST" : '.*\([dwmy]\)'`
  if [ -z $ADJUST_UNIT ]
  then
    ADJUST_UNIT=d
  fi
  if [ $DATE_VERSION == "GNU" ]
  then
    case $ADJUST_UNIT in
      d)
        _GNU_UNIT=days
        ;;
      w)
        _GNU_UNIT=weeks
        ;;
      m)
        _GNU_UNIT=months
        ;;
      y)
        _GNU_UNIT=years
        ;;
      *)
    esac

    # GNU date handles month and year addition in a way that could cause
    # todo.txt again users to miss deadlines near the end of the month.
    #   $ date --version
    #   date (GNU coreutils) 6.10
    #   $ date -d "2015-01-31 1 month" +%F
    #   2015-03-03      -- Yikes! Task probably due on 2015-02-28
    #   $ date -d "2016-02-29 2 years" +%F
    #   2018-03-01      -- Yikes! Task probably due on 2018-02-28
    # We'll work around this problem with some additional logic.
    if [ $_GNU_UNIT == "days" ] || [ $_GNU_UNIT == "weeks" ] || [ ${ORIGINAL:8:2} -le "28" ]
    then
      # No workaround if users are adjusting by days OR the day of the month
      # isn't in the danger zone.
      NEW_DATE=`date -d "$ORIGINAL $ADJUST_NUM $_GNU_UNIT" +$DATE_FORMAT`
    else
      _ORIGINAL_MONTH_DAY_ONE=${ORIGINAL:0:8}01
      _NEW_MONTH_DAY_ONE=`date -d "$_ORIGINAL_MONTH_DAY_ONE $ADJUST_NUM $_GNU_UNIT" +$DATE_FORMAT`
      _NEW_MONTH_LAST_DAY=`date -d "$_NEW_MONTH_DAY_ONE 1 month - 1 day" +$DATE_FORMAT`
      if [ ${ORIGINAL:8:2} -lt ${_NEW_MONTH_LAST_DAY:8:2} ]
      then
        NEW_DATE=${_NEW_MONTH_DAY_ONE:0:8}${ORIGINAL:8:2}
      else
        NEW_DATE=${_NEW_MONTH_DAY_ONE:0:8}${_NEW_MONTH_LAST_DAY:8:2}
      fi
    fi

  elif [ $DATE_VERSION == "BSD" ]
  then
    # BSD date handles month and year addition near the end of the month
    # better than GNU, but still not quite perfectly.
    #   $ man date | tail -n 1
    #   FreeBSD 10.2             May 7, 2015                FreeBSD 10.2
    #   $ date -j -v+1y -f %F 2016-02-29 +%F
    #   2017-03-01      -- Yikes! Task probably due on 2017-02-28
    #   $ date -j -v-1m -v+1y -v+1m -f %F 2016-02-29 +%F
    #   2017-02-28      -- That's more like it
    # So for BSD, we'll treat year adjustments carefully.
    if [ $ADJUST_UNIT != "y" ]
    then
      NEW_DATE=`date -j -v+${ADJUST_NUM}${ADJUST_UNIT} -f $DATE_FORMAT $ORIGINAL +$DATE_FORMAT`
    else
      NEW_DATE=`date -j -v-1m -v+${ADJUST_NUM}${ADJUST_UNIT} -v+1m -f $DATE_FORMAT $ORIGINAL +$DATE_FORMAT`
    fi
  else
    error "Unknown date implementation. Bailing out."
  fi
}

# Determine which date implementation is installed on this machine
function determine_date_version()
{
  date -v 1d 1>/dev/null 2>/dev/null

  # BSD flavor accepts the -v (value) option without complaint
  if [ 0 -eq $? ]
  then
    DATE_VERSION="BSD"

  # GNU flavor says so in the --version output
  elif [[ $(date --version) =~ GNU ]]
  then
    DATE_VERSION="GNU"

  # else not supported
  else
    error "Unknown date implementation. Bailing out."

  fi
}

function error()
{
  echo "error: $@" >&2
  exit 1
}
