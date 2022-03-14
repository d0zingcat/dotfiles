#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Convert Human-Readable Date To Epoch
# @raycast.mode silent
# @raycast.packageName Conversions
#
# Optional parameters:
# @raycast.icon ⏱
# @raycast.needsConfirmation false
# @raycast.argument1 {"type": "text", "placeholder": "Date"}
#
# Documentation:
# @raycast.description Convert human-readable date to timestamp epoch.
# @raycast.author Siyuan Zhang | d0zingcat
# @raycast.authorURL https://github.com/kastnerorz | https://d0zingcat.dev

date=${1}
length=${#date}
if [[ $length -eq 19 ]]; then
	epoch=$(echo $(date -jRuf "%F %T" "$date" "+%s"))
	echo -n "$epoch" | pbcopy
elif [[ $length -eq 10 ]]; then
	epoch=$(echo $(date -jRuf "%F %T" "$date 00:00:00" "+%s"))
	echo -n "$epoch" | pbcopy
elif [[ $length -eq 8 ]]; then
	yyyy=$(echo $date | cut -c1-4)
	mm=$(echo $date | cut -c5-6)
	dd=$(echo $date | cut -c7-8)
	epoch=$(echo $(date -jRuf "%F %T" "$yyyy-$mm-$dd 00:00:00" "+%s"))
	echo -n "$epoch" | pbcopy
else
	echo "Invalid date format."
	exit 1
fi

echo "Converted $date to $epoch"
