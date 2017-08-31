#!/bin/sh

upSeconds=`/usr/bin/cut -d. -f1 /proc/uptime`
secs=$(($upSeconds%60))
mins=$(($upSeconds/60%60))
hours=$(($upSeconds/3600%24))
days=$(($upSeconds/86400))
#WEATHER=`curl -s "http://rss.accuweather.com/rss/liveweather_rss.asp?metric=1&locCode=EUR|RO|RO010|BUCHAREST|" | grep '<description>Currently in' | sed -e 's/^[ \t]*//' | cut -b27- |sed 's/\&\#176\;//g'| sed 's/ C / °C /g'`
WEATHER=`curl -s "http://rss.accuweather.com/rss/liveweather_rss.asp?metric=1&locCode=EUR|RO|RO010|VALSANESTI|" | grep '<description>Currently in' | sed -e 's/^[ \t]*//' | cut -b27- |sed 's/\&\#176\;//g'| sed 's/ C /°C /g'`
HOSTNAME=`/bin/hostname`
DATE=`date +"%A, %e %B %Y, %R"`
OS=`uname -srvmo`
UP=`printf "%d days, %02dh %02dm %02ds " "$days" "$hours" "$mins" "$secs"`
SPEED=$(( `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq | awk {'print $1'}`/1000))
TEMP=`cat /sys/class/thermal/thermal_zone0/temp | awk '{printf("%.1f""°C\n",$1/1e3)}'`
Tmem=`free -t -m | grep 'Mem:' | awk {'print $2'}`
Umem=`free -t -m | grep 'Mem:' | awk {'print $3'}`
Fmem=`free -t -m | grep 'Mem:' | awk {'print $4'}`
PROC=`ps ax | wc -l | tr -d " "`
USER=`users | wc -w`
Tsd=`df -h | grep 'dev/root' | awk '{print $2}'`
Usd=`df -h | grep 'dev/root' | awk '{print $3}'`
Fsd=`df -h | grep 'dev/root' | awk '{print $4}'`
Tusb=`df -h | grep 'media/usb.drive' | awk '{print $2}'`
Uusb=`df -h | grep 'media/usb.drive' | awk '{print $3}'`
Fusb=`df -h | grep 'media/usb.drive' | awk '{print $4}'`
#WAN=`wget -qO - ipecho.net/plain | tail`
#WAN=`wget -qO - ifconfig.co/x-real-ip`
#WAN=$(curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//')
WAN=$(dig +short myip.opendns.com @resolver1.opendns.com)
LAN=$(/sbin/ifconfig | awk -v i=2 -v j=1 'FNR ==  i{print $2}' | cut -b6-50)
echo "
\033[0;32m
    .~~.   .~~.
   '. \ ' ' / .'  \033[0;36m   _    _  ___  __    __  __  __  __  ___    ____  __     ___   ___  __       _  _  __   __    ___  ___  \033[0;31m
    .~ .~~~..~.   \033[0;36m  ( \/\/ )(  _)(  )  / _)/  \(  \/  )(  _)  (_  _)/  \   (  ,) (  ,\(  ) ___ ( \/ )(  ) (  )  / __)(  _) \033[0;31m 
   : .~.'~'.~. :  \033[0;36m   \    /  ) _) )(__( (_( () ))    (  ) _)    )( ( () )   )  \  ) _/ )( (___) \  / /__\  )(__ \__ \ ) _) \033[0;31m
  ~ (   ) (   ) ~ \033[0;36m    \/\/  (___)(____)\__)\__/(_/\/\_)(___)   (__) \__/   (_)\_)(_)  (__)       \/ (_)(_)(____)(___/(___) \033[0;31m
 ( : '~'.~.'~' : )\033[0;33m   ___   __  _    _  ___  ___   ___  ___     ___  _  _    ___    __   ___  ___  ___  ___  ___   ___   _  _    ___  __   ____  \033[0;31m
  ~ .~ (   ) ~. ~ \033[0;33m  (  ,\ /  \( \/\/ )(  _)(  ,) (  _)(   \   (  ,)( \/ )  (  ,)  (  ) / __)(  ,\(  ,)(  _)(  ,) (  ,) ( \/ )  (  ,\(  ) (___ \ \033[0;31m
   (  : '~' :  )  \033[0;33m   ) _/( () )\    /  ) _) )  \  ) _) ) ) )   ) ,\ \  /    )  \  /__\ \__ \ ) _/ ) ,\ ) _) )  \  )  \  \  /    ) _/ )(   / __/ \033[0;31m
    '~ .~~~. ~'   \033[0;33m  (_)   \__/  \/\/  (___)(_)\_)(___)(___/   (___/(__/    (_)\_)(_)(_)(___/(_)  (___/(___)(_)\_)(_)\_)(__/    (_)  (__) (____) \033[0;31m
        '~' \033[0;37m

Status:
   system....................: $OS
   date:.....................: $DATE
   uptime....................: $UP
   cpu speed.................: 4 x $SPEED""MHz
   temperature...............: $TEMP
   memory....................: $Tmem""MB (Total) / $Umem""MB (Used) / $Fmem""MB (Free)
   running processes.........: $PROC
   ssh users (last minute)...: $USER
   disk space................: $Tsd""B (Total) / $Usd""B (Used) / $Fsd""B (Free) on system drive
                               $Tusb""B (Total) / $Uusb""B (Used) / $Fusb""B (Free) on storage drive

IP Adresses:
   external..................: $WAN
   local (wired).............: $LAN

Hostname.....................: $HOSTNAME

Weather......................: $WEATHER
\033[0;37m " > /var/run/motd.dynamic
