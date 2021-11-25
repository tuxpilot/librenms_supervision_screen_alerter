#!/bin/bash

while IFS= read -r line
	do 	timestamp_added=$(echo "${line}" | awk -F ' ' '{ print $1 }')
		actual_timestamp=$(date +%s)
		timestamp_for_delete=$((${timestamp_added}+86400))

		if [[ "${actual_timestamp}" -lt "${timestamp_for_delete}" ]]
			then	echo "${line}" >> temp_ignore_a.txt 2>&1
		fi
done < temp_ignore.txt

if [[ -e temp_ignore_a.txt ]]
	then	mv temp_ignore_a.txt temp_ignore.txt
fi

