#!/bin/bash

echo "T H I S     P R O G R A M     W I L L     R E S E T     D E V I C E     A T     F A C T O R Y     S T A T U S"
sleep 2
echo "All variables will be changed with default values. Are you sure? [Y/N]"

read answer

if [ $answer == "Y" ] || [ $answer == "y" ]; then
  sleep 2
  echo "Now will be deleted all the data in pwm.db and all the pwm csv files. Proceed? [Y/N]"

	read answer

	if [ $answer == "Y" ] || [ $answer == "y" ]; then
	  echo "  >>> Stopping PWM service..."
	  killall pwm_daemon
	
	  echo "  >>> Removing existing db file..."
	  rm -rf /var/www/html/storage/pwm.db /var/www/html/storage/pwm.db-wal /var/www/html/storage/pwm.db-shm

	  echo "  >>> Copying reference db file..."
	  cp /var/www/html/storage/sys/default/pwm.db.ref /var/www/html/storage/pwm.db
	  chown www-data:www-data /var/www/html/storage/pwm.db

	  echo "  >>> Removing config csv files..."
	  rm -rf /var/www/html/csv/*.csv

	  echo "  >>> Reseting remote credentials..."
	  cp /var/www/html/storage/sys/default/hostapd.conf.ref /etc/hostapd/hostapd.conf

	  echo "  >>> Reseting web credentials..."
	  cp /var/www/html/storage/sys/default/.htpasswd.ref /var/

	  echo "  >>> Change to default network address..."
	  cp /var/www/html/storage/sys/default/dhcpcd.conf.ref /etc/dhcpcd.conf

	  echo "  >>> Reseting hostname..."
	  #OLD_HOST=$(hostname | tr -d '\r\n')
	  #NEW_HOST=pwm
	  #hostnamectl set-hostname ${NEW_HOST}
	  #sed -i "s/\s${OLD_HOST}$/\\t${NEW_HOST}/Ig" /etc/hosts
	  cp /var/www/html/storage/sys/default/hostname.ref /etc/hostname
	  cp /var/www/html/storage/sys/default/hosts.ref /etc/hosts

	  echo "  >>> Reseting email address..."
	  #echo "test@test.com" > /var/www/html/storage/sys/MAIL
	  cp /var/www/html/storage/sys/default/mail.ref /var/www/html/storage/sys/MAIL

	  echo "  >>> ALL DONE"
	  sleep 2

	  echo " After poweroff, the device will be erased and ready to go at client..."
	  sleep 2

	  echo " The system will be closed now..."
	  sleep 2
	  /sbin/shutdown -h now

	else
	  echo "Exiting program. Data unchanged..."
	  echo " "
	fi
else
	echo "Exiting program. No changes..."
	echo " "
fi
