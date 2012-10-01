#!/bin/bash
#
# AUTHOR: Oleg Brodkin
#
# DATE:   Oct-1-2012
#
# DESCRIPTION: to migrate cobbler DNS to freeIPA DNS 
#
# PRE-REQUISIT: DNS master file *.zone 
#
# INPUT:        
#
# OUTPUT:      IPA commands for replicating DNS entries 
#              
# RELEASE NOTE: 
#              1.0 
#

readonly DNSMASTER="/var/named/masters/cgtanalytics.com.zone"
readonly MAINDOMAIN="cgtanalytics.com"

grep "IN A" $DNSMASTER | awk '{print $1," ",$4 }' | while read host ip
do

    if [ "X"${host:0:2} == "XIN" ] || [ ${host:0:1} == ";" ]
    then
	continue
    fi

    echo -en "\n"$host "\t ["$ip"] "

    # if ping fails, echo OFFLINE
    echo -en " --ONLINE"
    ( `ping -c 4 -q ${ip} > /dev/null` ) || ( echo -en "\033[6DOFFLINE" )
    wait

done


grep "IN CNAME" $DNSMASTER | awk '{print $1," ",$4 }' | while read cname host
do

    echo -en "\n"$cname "\t" $host

    echo -en " --ONLINE"
    if [ "X"${host:(-1)} == "X." ] 
    then
	( `ping -c 4 -q ${host} > /dev/null` ) || ( echo -en "\033[6DOFFLINE" )
    else
	( `ping -c 4 -q ${host}"."${MAINDOMAIN} > /dev/null` ) || ( echo -en "\033[6DOFFLINE" )
    fi
    wait

done

