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
intCurrentConfig=0
intTotalConfigs=0
intTickets=$(echo ${arrTickets}| jq "length")
#iterates through the array for the amount of tickets
while [ ${intCurrent} -lt ${intTickets} ]; do
	#checks each ticket to see if its equal to the inputed id
	if [ ${strTicketId} = $(echo ${arrTickets} | jq -r .[${intCurrent}].ticketID) ]; then
		#grabs all of the desired info from the json array
		strRequestor=$(echo ${arrTickets} | jq -r .[$intCurrent].requestor)
		strSubmissionDate=$(echo ${arrTickets} | jq -r .[$intCurrent].submissionDate)
		strSoftwarePackages=$(echo ${arrTickets} | jq -r .[$intCurrent].softwarePackages)
		strStandardConfig=$(echo ${arrTickets} | jq -r .[$intCurrent].standardConfig)
		strStartTime=$(date +"%Y-%m-%d %H:%M:%S")
		echo "TicketID: $strTicketId" >> configurationLogs/${strTicketId}.log 
		echo "Start DateTime: $strStartTime" >> configurationLogs/${strTicketId}.log
		echo "Requestor: $strRequestor" >> configurationLogs/${strTicketId}.log
		echo "External IP Address: $strIP" >> configurationLogs/${strTicketId}.log
		echo "Hostname: $strHostName" >> configurationLogs/${strTicketId}.log
		echo "Standard Configuration: $strStandardConfig" >> configurationLogs/${strTicketId}.log
		echo " " >> configurationLogs/${strTicketId}.log
		#sets up each config and sends it  to the log
		#current known bugs:iterates a extra time
#		for config in $(echo ${arrTickets} | jq -r .[${intCurrent}].additionalConfigs[].config); do
#			strConfigName=$(echo ${arrTickets} | jq -r .[${intCurrent}].additionalConfigs[$intConfigIter].name)
#			echo "additonalConfig - $strConfigName" >> configurationLogs/${strTicketId}.log
#			strConfig=$(echo ${arrTickets} | jq -r .[${intCurrent}].additionalConfigs[$intConfigIter].config)
#			strArguments=$(echo ${strConfig} | sed 's/^[^[:space:]]* //')
#			strCommand=$(echo ${strConfig}  | sed 's/ .*//')
#			if [ $strCommand = "touch" ]; then
#				strTempDir=$(echo "${strConfig}" | sed 's/^.{0,5}//')
#				sudo mkdir -p $strTempDir
#				sudo rm -r $strTempDir
#			fi
#			eval "$strCommand $strArguments"
#			((intConfigIter++))
#		done
		strAdditonalConfigs=$(echo ${arrTickets} | jq -r .[${intCurrent}].additionalConfigs)
		intTotalConfigs=$(echo ${strAdditonalConfigs} | jq length)
		echo $intTotalConfigs
		while [ ${intCurrentConfig} -lt ${intTotalConfigs} ];do
			strConfig=$(echo ${strAdditonalConfigs} | jq .[${intCurrentConfig}])
			strCommand=$(echo ${strConfig} | jq -r .config)
			if [[ $strCommand == *"touch"* ]]; then
				strPath=$(echo ${strCommand})
				strPath=$(echo $(echo ${strPath}) | sed -e 's/touch //')
				strPath=$(echo $(echo ${strPath}) | sed -e 's![^/]*$!!')
				eval $(sudo mkdir -p ${strPath})
			fi
			eval $(sudo ${strCommand})
			echo "Additonal Config - $(echo ${strConfig} | jq -r .name)  -  $(date +'%s')" >> configurationLogs/${strTicketId}.log
			((intCurrentConfig++))
		done
		echo " " >> configurationLogs/${strTicketId}.log
		#sets up each package and sends it to the log
		for package in $(echo ${arrTickets} | jq -r .[${intCurrent}].softwarePackages[].install); do
			strPackage=$(echo ${arrTickets} | jq -r .[${intCurrent}].softwarePackages[$intPackageIter].name)
			echo "softwarePackage - $strPackage  -  $(date +'%s')" >> configurationLogs/${strTicketId}.log
			yes | sudo apt-get install ${package}
			((intPackageIter++))
		done
		#for package in $(echo ${arrTickets} | jq -r .[${intCurrent}].softwarePackages[].install); do
		#	${package} --version >> configurationLogs/${strTicketId}.log
		#done
		echo " " >> configurationLogs/${strTicketId}.log
		echo "TicketClosed" >> configurationLogs/${strTicketId}.log
		echo " " >> configurationLogs/${strTicketId}.log
		echo "Completed $(date +'%Y-%m-%d %H:%M')" >> configurationLogs/${strTicketId}.log
	fi
	((intCurrent++))
done
