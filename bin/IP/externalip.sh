#!/bin/sh

# get external IP address
# used for outgoing Internet connections
# see: https://github.com/rsp/scripts/blob/master/externalip.md

case "$1" in
	""|dns)	dig +short myip.opendns.com @resolver1.opendns.com ;;
	http) curl -s http://whatismyip.akamai.com/ && echo ;;
	https) curl -s https://4.ifcfg.me/ ;;
	ftp) echo close | ftp 4.ifcfg.me | awk '{print $4; exit}' ;;
	telnet) nc 4.ifcfg.me 23 | grep IPv4 | cut -d' ' -f4 ;;
	*) echo Bad argument >&2 && exit 1 ;;
esac