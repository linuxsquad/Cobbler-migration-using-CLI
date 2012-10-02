
These scripts are to assist with migration from cobbler V1.6 and bind to combination of 
cobbler V2.2.3 and freeIPA.

System configuration imported to cobbler server using <export_systems.sh> script. No other information will be migrated, just system configuration. 

DNS/bind data will be ported to freeIPA using <export_dns2ipa.sh> script.

In addition to basic functionality, scripts will check whether a system online and it has record in DNS. This to help weed out unused/removed/recycled/etc computers.


