#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Convert Epoch to Human-Readable Date
# @raycast.mode silent
# @raycast.packageName Conversions
#
# Optional parameters:
# @raycast.icon ⏱
# @raycast.needsConfirmation false
# @raycast.argument1 {"type": "text", "placeholder": "Timestamp Epoch"}
#
# Documentation:
# @raycast.description Convert epoch to human-readable date.
# @raycast.author Siyuan Zhang | d0zingcat
# @raycast.authorURL https://github.com/kastnerorz | https://d0zingcat.dev

epoch=${1}
size=${#epoch}
if [[ $size == "10" ]]; then
	human=$(echo $(date -r $epoch "+%F %T"))
	echo -n "$human" | pbcopy
elif [[ $size == "13" ]]; then
	human=$(echo $(date -r $(($epoch / 1000)) "+%F %T"))
	echo -n "$human" | pbcopy
else
	echo 'invalid data(valid length: 10 or 13)'
	exit 1
fi
echo "Converted $epoch to $human"
