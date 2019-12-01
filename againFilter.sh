#!/usr/bin/env bash

#Copyright (C) 2019 David Whitmarsh
#
# This program is free software: you can redistribute it and/or modify it 
# under the terms of the GNU General Public License as published by 
# the Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.

# This program is distributed in the hope that it will be useful, 
# but WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License 
# along with this program. If not, see http://www.gnu.org/licenses/.

source `dirname $0`/againHelpers.sh

readonly SED_DATE_RE="[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}"
readonly BASH_DATE_RE="[0-9]{4}-[0-9]{2}-[0-9]{2}"

determine_date_version
today

while IFS= read -r LINE || [[ -n "$LINE" ]]; do
    if [[ "$LINE" =~ .*t:$BASH_DATE_RE.* ]]
    then 
      THRESHOLD_DATE=$(echo "$LINE" | sed "s/.*t:\($SED_DATE_RE\).*/\1/")
      #echo "LINE is : $LINE"
      #echo "THRESHOLD_DATE is $THRESHOLD_DATE"
      #echo "TODAY is $TODAY"
      if [[ "$THRESHOLD_DATE" > "$TODAY" ]]
      then
        :
        #echo "Threshold > Today"
        # Don't show it
      else
        #echo "Threshold <= Today"
        # Show it
        echo "$LINE"
      fi 
    else 
      echo "$LINE"
    fi
done < "${1:-/dev/stdin}"
