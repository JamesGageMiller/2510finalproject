#! /bin/bash

#grabs the 
strUrl="https://www.swollenhippo.com/ServiceNow/systems/devTickets.php"
strIP=$1
strTicketId=$2

# get the array from the given url
arrTickets=$(curl ${strUrl} | jq -r)
#debug statement
#echo $arrTickets
intTickets = 0
for "ticketID" in "$arrTickets"; do
	(($intTickets++))
done
#debug stateent
echo $intTickets
#initilize two ints, one to say that 
intDesiredTicket=0
intCurrent=0
while [ "$intCurrent" -lt "$intTickets" ]; do
	if( $strTicketId == $[echo ${arrTickets} | jq -r .[$intCurrent].ticketID] ); then
		$intDesiredTicket = $intCurrent
	fi
	(($intCurrent+1))
done
echo $intDesiredTicket

