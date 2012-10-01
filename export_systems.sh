#!/bin/bash
#
# AUTHOR: Oleg Brodkin
#
# DATE:   Sep-28-2012
#
# DESCRIPTION: to migrate from cobbler 1.6 (monkey) to cobbler 2.2.3 (cgta-srv-01v01) 
#              replication functionality could not be used due to significant gap in 
#              versions. Instead, system configuration can be exported and imported
#              back to the new cobbler server using command line
#
# PRE-REQUISIT: exporting from: cobblerd 1.6
#               importing to:   cobblerd 2.2.3
#
# INPUT:       no command line options needed or processed
#
# OUTPUT:      2.2.3 cobbler commands will be printed to stdout. 
#              
# RELEASE NOTE:
#             1.0 update COBBLER_DEFLT_PROFILE variable to reflect a profile 
#                 you want to use on the new cobbler server
#          
#             1.1 script will check whether a node online (using its IP ADDR)
#                 and whether its HOSTNAME exists in DNS
#

readonly TEMPFILE="/tmp/cobbler_system.txt"
readonly COBBLER_DEFLT_PROFILE="xubuntu12.04_WS"

cobbler system list | while read node
do
    cobbler system report $node > $TEMPFILE
    
    name=`cat $TEMPFILE | awk -F " : " '/system/{print $2}' `
    host=`cat $TEMPFILE | awk -F " : " '/hostname/{print $2}' `
    dns=`cat $TEMPFILE | awk -F " : " '/dns name/{print $2"+"}' `
    interface=`cat $TEMPFILE | awk -F " : " '/interface/{print $2"+"}' `
    mac=`cat $TEMPFILE | awk -F " : " '/mac address/{print $2"+"}' `
    ip=`cat $TEMPFILE | awk -F " : " '/ip address/{print $2"+"}' `

    echo -en "#---"$name

    # if ping fails, echo OFFLINE will erase ONLINE
    echo -en " --ONLINE"
    ( `ping -c 4 -q ${ip%%+*} > /dev/null` ) || ( echo -en "\033[6DOFFLINE" )
    wait
 
    # if dig failes, echo NODNS will erase INDNS
    echo -en " --INDNS"
    ( `dig "${dns%%+*}" | grep -q "${ip%%+*}" > /dev/null` ) || ( echo -en "\033[5DNODNS")
    wait

    echo -e "\ncobbler system add --name="${name}" --hostname="${host}"  \
--dns-name="${dns%%+*}" --profile="${COBBLER_DEFAULT_PROFILE}" \
--netboot-enabled=0 --mac="${mac%%+*}" --ip-address="${ip%%+*}
    echo "wait"

    if [ "X${interface#*+}" != "X" ] 
    then
	interface2=${interface#*+?}
	mac2=${mac#*+?}
	ip2=${ip#*+?}
	    echo "cobbler system edit --name="${name}" --interface="${interface2%+}" \
--mac="${mac2%+}"  --ip-address="${ip2%+}
	    echo "wait"

    fi

done