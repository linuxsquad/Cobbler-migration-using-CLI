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

source ./pinglib_inc.sh

readonly DNSMASTER="/var/named/masters/cgtanalytics.com.zone"
readonly MAINDOMAIN="cgtanalytics.com"

echo "#=== Exporting A Records"
grep "IN A" $DNSMASTER | awk '{print $1," ",$4 }' | while read host ip
do

    if [ "X"${host:0:2} == "XIN" ] || [ ${host:0:1} == ";" ]
    then
	continue
    fi

    echo -en "\n#-- "$host "\t ["$ip"] --"

    # if ping fails, echo OFFLINE
    onlineStatus ${ip} 

    echo -e "\n ipa dnsrecord-add "${MAINDOMAIN}" "${host}" --a-rec "${ip}" --a-create-reverse; wait"

done

echo "#=== Exporting CNAME Records"
grep "IN CNAME" $DNSMASTER | awk '{print $1," ",$4 }' | while read cname host
do

    echo -en "\n#-- "$cname "\t" $host" --"

    if [ "X"${host:(-1)} == "X." ] 
    then
	onlineStatus ${host} 
    else
	onlineStatus ${host}"."${MAINDOMAIN}
    fi

    echo -e "\n ipa dnsrecord-add "${MAINDOMAIN}" "${cname}" --cname-rec "${host}"; wait"

done

