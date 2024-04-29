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
while [ "$intIndex" -lt "$intTickets" ]; do
	if( $strTicketId == $[echo ${arrTickets} | jq -r .[$intIndex].ticketID] ); then
		strRequestor=$(echo ${arrResults} | jq -r .[$intIndex].requestor)
		strSubmissionDate=$(echo ${arrResults} | jq -r .[$intIndex].submissionDate)
		strSoftwarePackages=$(echo ${arrResults} | jq -r .[$intIndex].softwarePackages)
		strStandardConfig=$(echo ${arrResults} | jq -r .[$intIndex].standardConfig)
		strStartTime=$(date + "%Y-%M-%D %H:%M:%S") 
	fi
	(($intIndex++))
done
