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
intCurrent=0
intTickets=$(echo ${arrTickets}| jq "length")
#iterates through the array for the amount of tickets
while [ "$intCurrent" -lt "$intTickets" ]; do
	#checks each ticket to see if its equal to the inputed id
	if( $strTicketId == $[echo ${arrTickets} | jq -r .[$intCurrent].ticketID] ); then
		#grabs all of the desired info from the json array
		strRequestor=$(echo ${arrResults} | jq -r .[$intCurrent].requestor)
		strSubmissionDate=$(echo ${arrResults} | jq -r .[$intCurrent].submissionDate)
		strSoftwarePackages=$(echo ${arrResults} | jq -r .[$intCurrent].softwarePackages)
		strStandardConfig=$(echo ${arrResults} | jq -r .[$intCurrent].standardConfig)
		strStartTime=$(date + "%Y-%M-%D %H:%M:%S")
		#sets up each config and sends it  to the log
		for config in $(echo ${arrTickets} | jq -r .[${intCurrent}].additionalConfigs[].config); do
			strConfig=$(echo {$arrTickets} | jq -r .[${intCurrent}].additionalConfigs[].name)
			$strConfig >> configurationLogs/${strTicketId}.log 
			eval $config
		done
		#sets up each package and sends it to the log
		for package in $(echo ${arrTickets} | jq -r .[${intCurrent}].softwarePackages[].install); do
			strPackage=$(echo ${arrTickets} | jq -r .[${intCurrent}].softwarePackages[].name)
			$strPackage >> configurationLogs/${strTicketId}.log
			yes | sudo apt-get install ${package}
		done
	fi
	(($intCurrent++))
done
