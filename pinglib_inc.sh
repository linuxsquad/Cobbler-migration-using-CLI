#
# included by export_dns2ipa.sh
# included by export_systems.sh

function onlineStatus() {

   if [ -z "$1" ]
   then
       echo -n "  ERR: Host name/IP address missing" 
       return 1
   fi

   local host=$1

   if ( `ping -c 4 -q ${host} > /dev/null` ) 
   then
       echo -n "ONLINE"
   else
       echo -n "OFFLINE"
   fi
   wait

   if [ -z "$2" ]
   then
       return 0
   fi

   local dns=$2

   if ( `dig "${dns}" | grep -q "${host}" > /dev/null` )
   then
       echo -n ", DNS=YES"
   else
       echo -n ", DNS=NO"
   fi
   wait

   return 0

}