#!/usr/bin/env bash

CHAIN_tor=`iptables -S | grep tor | wc -l`
CHAIN_isc=`iptables -S | grep isc | wc -l`

# a tor exit IP
ipset -N tor-exit-ip iphash

wget -q https://check.torproject.org/cgi-bin/TorBulkExitList.py -O -|sed '/^#/d' | \

while read IP_tor
do
    ipset -q -A tor-exit-ip $IP_tor
done


# a ISC bad IP list

ipset -N isc iphash

wget -q https://isc.sans.edu/ipsascii.html?limit=1000 -O -|sed -e '/^#/d' |awk '{ print $1 }'| sed -e 's/^[0]*//' -e 's/\.[0]*/\./g' | sed -e 's/\.\./\.0\./g' | \

while read IP_isc
do
    ipset -q -A isc $IP_isc
done


# drop IP addr in iptables

if [ $CHAIN_tor -eq "0" ]
then
    iptables -I INPUT -m set --match-set tor-exit-ip src -j DROP
fi


if [ $CHAIN_isc -eq "0" ]
then
    iptables -I INPUT -m set --match-set isc src -j DROP
fi
