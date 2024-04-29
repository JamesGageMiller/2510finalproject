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
intPackageIter=0
intConfigIter=0
intTickets=$(echo ${arrTickets}| jq "length")
#iterates through the array for the amount of tickets
while [ "$intCurrent" -lt "$intTickets" ]; do
	#checks each ticket to see if its equal to the inputed id
	if [ ${strTicketId} = $(echo ${arrTickets} | jq -r .[${intCurrent}].ticketID) ]; then
		#grabs all of the desired info from the json array
		strRequestor=$(echo ${arrTickets} | jq -r .[$intCurrent].requestor)
		strSubmissionDate=$(echo ${arrTickets} | jq -r .[$intCurrent].submissionDate)
		strSoftwarePackages=$(echo ${arrTickets} | jq -r .[$intCurrent].softwarePackages)
		strStandardConfig=$(echo ${arrTickets} | jq -r .[$intCurrent].standardConfig)
		strStartTime=$(date + "%Y-%m-%d %H:%M:%S")
		echo "TicketID: $strTicketId" >> configurationLogs/${strTicketId}.log 
		#insert starttime log output
		echo "Requestor: $strRequestor" >> configurationLogs/${strTicketId}.log
		echo "External IP Address: $strIP" >> configurationLogs/${strTicketId}.log
		echo "Hostname: $strHostName" >> configurationLogs/${strTicketId}.log
		echo "Standard Configuration: $strStandardConfig" >> configurationLogs/${strTicketId}.log
		echo " " >> configurationLogs/${strTicketId}.log
		#sets up each config and sends it  to the log
		for config in $(echo ${arrTickets} | jq -r .[${intCurrent}].additionalConfigs[].config); do
			strConfig=$(echo {$arrTickets} | jq -r .[${intCurrent}].additionalConfigs[$intConfigIter].name)
			echo "additonalConfig - $strConfig" >> configurationLogs/${strTicketId}.log
			if [ $(echo ${strConfig} | grep -w "touch") = "touch" ]; then
				strTempDir = $(echo ${strConfig} | cut -d "touch")
				sudo mkdir -p ${strTempDir} 
			fi
			eval $config
			((intConfigIter++))
		done
		echo " " >> configurationLogs/${strTicketId}.log
		#sets up each package and sends it to the log
		for package in $(echo ${arrTickets} | jq -r .[${intCurrent}].softwarePackages[].install); do
			strPackage=$(echo ${arrTickets} | jq -r .[${intCurrent}].softwarePackages[$intPackageIter].name)
			echo "softwarePackage - $strPackage" >> configurationLogs/${strTicketId}.log
			yes | sudo apt-get install ${package}
			((intPackageIter++))
		done
		echo " " >> configurationLogs/${strTicketId}.log
		echo "TicketClosed" >> configurationLogs/${strTicketId}.log
		echo " " >> configurationLogs/${strTicketId}.log
		echo "Completed %Y-%m-%d %H:%M" >> configurationLogs/${strTicketId}.log
	fi
	((intCurrent++))
done
