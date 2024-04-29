#! /bin/bash

#grabs the URL, and inputed parameters
mkdir -p configurationLogs
strUrl="https://www.swollenhippo.com/ServiceNow/systems/devTickets.php"
strIP=$1
strTicketId=$2
touch configurationLogs/${strTicketId}.log
strHostName=$(hostname)
# get the array from the given url
arrTickets=$(curl ${strUrl} | jq -r)
#debug statement
#echo $arrTickets
#int to keep track of the index of the while loop
intIndex=0
intTickets=$(echo ${arrTickets}| jq "length")
while [ "$intCurrent" -lt "$intTickets" ]; do
	if( $strTicketId == $[echo ${arrTickets} | jq -r .[$intCurrent].ticketID] ); then
		strRequestor=$(echo ${arrResults} | jq -r .[$intCurrent].requestor)
		strSubmissionDate=$(echo ${arrResults} | jq -r .[$intCurrent].submissionDate)
		strSoftwarePackages=$(echo ${arrResults} | jq -r .[$intCurrent].softwarePackages)
		strStandardConfig=$(echo ${arrResults} | jq -r .[$intCurrent].standardConfig)
		strStartTime=$(date + "%Y-%M-%D %H:%M:%S")
		for config in $(echo ${arrTickets} | jq -r .[${intCurrent}].additionalConfigs[].config); do
			strConfig=$(echo {$arrTickets} | jq -r .[${intCurrent}].additionalConfigs[].name)
			strConfig >> configurationLogs/${strTicketId}.log 
			eval $config
		done
		for package in $(echo ${arrTickets} | jq -r .[${intCurrent}].softwarePackages[].install); do
			
		done
	fi
	(($intCurrent++))
done
