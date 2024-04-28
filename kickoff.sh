#! /bin/bash
# Description: Copies and runs automation script on GCP remote server
# Author: Ben Burchfield
# Date: 17 April 2024 

strIP=$1
strTicketID=$2
strUsername=$3
eval "$(ssh-agent -s)"

# The location of my gcp ssh key is in the .ssh directory
ssh-add .ssh

scp -i .ssh/gcp serverSetup.sh "${strUsername}"@"${strIP}":/home/"${strUsername}"
ssh ${strUsername}@${strIP} "chmod 755 serverSetup.sh"
ssh ${strUsername}@${strIP} "./serverSetup.sh ${strIP} ${strTicketID}"
