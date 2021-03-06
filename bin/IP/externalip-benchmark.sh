#!/bin/bash

# tests the speed of various services for externalip:
# https://github.com/rsp/scripts/blob/master/externalip.md
# converted from the ajax-cdn-speed-test:
# https://github.com/rsp/ajax-cdn-speed-test
# by Rafał Pocztarski https://rsp.github.io/

# hosts taken on 2015-04-02 from:
# http://unix.stackexchange.com/questions/22615
# https://coderwall.com/p/lyrjsq/extract-your-external-ip-using-command-line-tools
# using only those that output IP only (with no need to parse output)

read -d '' urls << 'END'
//ifconfig.me/
//icanhazip.com/
//ip.appspot.com/
//curlmyip.com/
//ident.me/
//tnx.nl/ip
//ipecho.net/plain
//whatismyip.akamai.com/
//wgetip.com/
//ip.tyk.nu/
//curlmyip.com/
//corz.org/ip
//bot.whatismyipaddress.com/
//ifcfg.me/
//ipof.in/txt
//l2.io/ip
//eth0.me/
END

pings=5
interval=0.2

httpl=
httpsl=
pingl=

for url in $urls
do
    echo -e "\nserver: $url"
	for protocol in http https
	do
	    purl="$protocol:$url"
	    cout=$(curl -m10 -L -sw "~over $protocol:\t%{time_total}s\n" $purl | tr -d '\n')
	    echo $cout
	    answer=$(echo $cout | cut -d'~' -f1)
	    stats=$(echo $cout | cut -d'~' -f1)
	    time=$(echo $cout | awk '{print $NF; exit}')
	    [ $protocol = http ] && httpl="$httpl$time http:$url - answer='$answer'\n"
	    [ $protocol = https ] && httpsl="$httpsl$time https:$url - answer='$answer'\n"
	done
	host=`echo $url | cut -d/ -f3`
	avgping=`ping -c $pings -i $interval $host | tail -1 | cut -d/ -f 5`
	[ -z "$avgping" ] && avgping=999999
    echo -e "average ping:\t$avgping""ms"
    pingl="$pingl$avgping""ms $url\n"
done

echo -e "\nBest http response times (using curl):"
echo -e "$httpl" | sort -n

echo -e "\nBest https response times (using curl):"
echo -e "$httpsl" | sort -n

echo -e "\nBest average ping times:"
echo -e "$pingl" | sort -n

echo -e "\n\nBut getting IP directly from a DNS server is the FASTEST method:\n"
time dig +short myip.opendns.com @resolver1.opendns.com
echo -e "\nBenchmark test finished! \n"

