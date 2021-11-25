#!/bin/bash

gpio -g mode 17 out
gpio -g write 17 1
rsyslog_file='/var/log/rsyslog/?????????????'
work_hour_start=0900
work_hour_end=1900

debug()
{
	echo "$(date +%Y-%m-%d@%H:%M:%S)  ${1}" >> debug.txt 2>&1
}
while true; do
		while IFS= read -r line_of_ignore
			do	device_to_ignore=$(echo "${line_of_ignore}" | awk -F ' ' '{ print $2 }')
				debug "device_to_ignore : ${device_to_ignore}"
				while IFS= read -r line_of_alert
					do	if [[ -z $(echo "${line_of_alert}" | grep "${device_to_ignore}") && ! -z "${line_of_alert}" && $(date +%H%M) > "${work_hour_start}" && $(date +%H%M) < "${work_hour_end}" && "${line_of_alert}" == *'[Critical]'* ]]
							then	debug "No device_to_ignore was greped in line_of_alert, and the line_of_alert contains a Critical alert, we ring the alarm!"
								echo "" > "${rsyslog_file}" 2>&1
								echo -e "${line_of_alert} \n" >> triggered_alerts.log 2>&1
								gpio -g write 17 0
								sleep 0.3
								omxplayer sound_alert_librenms.wav
								sleep 0.3
								gpio -g write 17 1
							
							else	debug "${device_to_ignore} n'a pas été grep dans les logs, RAS"
						fi
						if [[ $(date +%H%M) > "${work_hour_start}" && $(date +%H%M) < "${work_hour_end}" && "${line_of_alert}" != *'[Critical]'* && ! -z "${line_of_alert}" ]]
							then	debug "a END of Alert was greped, so we ignore this line of log"
						fi
				done < "${rsyslog_file}"
		done < temp_ignore.txt
		echo "" > "${rsyslog_file}" 2>&1
		debug "sleep 60 seconds until new check loop"
		debug "_____________________________________"
		sleep 60
done
