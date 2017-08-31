#!/bin/bash

ls /dev/sdb > /dev/null 2>&1
if [ $? == 0 ]; then echo "   ... dispozitiv detectat in slotul USB... Deconecteaza si reia programul..."; echo "   /dev/sdb detectat. Iesire din program..."; exit 1; fi
ls /dev/sdc > /dev/null 2>&1
if [ $? == 0 ]; then echo "   ... dispozitiv detectat in slotul USB... Deconecteaza si reia programul..."; echo "   /dev/sdc detectat. Iesire din program..."; exit 1; fi
ls /dev/sdd > /dev/null 2>&1
if [ $? == 0 ]; then echo "   ... dispozitiv detectat in slotul USB... Deconecteaza si reia programul..."; echo "   /dev/sdd detectat. Iesire din program..."; exit 1; fi
clear
echo " "
echo "   >>>  A C ES T    P R O G R A M    E X E C U T A     C L O N A R E A    A P A R A T U L U I   <<<"
echo " "
sleep 1
echo "   Trebuie sa urmati NUMAI instructiunile ce apar pe ecran..."
sleep 1
echo "   ... altfel clonarea va esua..."
sleep 1
echo " "
echo "   ... A T I    F O S T    A V E R T I Z A T !!"
echo " "
sleep 1
echo "   ATENTIE! Este util ca anterior clonarii sa fie resetat aparatul"
sleep 1
echo "   Verificati sa fie conectat DOAR micro SD cardul (/boot) si sticul USB (/)"
sleep 1
echo "   Noul stic USB si noul SD card NU trebuie sa fie inca introduse in aparat"
sleep 1
echo " "
echo "   Introduceti noul stic USB intr-un slot gol. Confirmati [Y] cand sunteti gata"
read answer
if [ $answer == "Y" ] || [ $answer == "y" ]; then
  ls /dev/sdb > /dev/null 2>&1
  if [ $? != 0 ]; then echo "   ...noul stic USB nedetectat. Iesire din program..."; echo " ";exit 1; fi
  sleep 1
  echo " "
  echo "   Acum, introduceti adaptorul USB cu noul micro SD card intr-un alt slot. Confirmati [Y] cand sunteti gata"
  read answer2
  if [ $answer2 == "Y" ] || [ $answer2 == "y" ]; then
    ls /dev/sdc > /dev/null 2>&1
    if [ $? != 0 ]; then echo "   ...noul micro SD card nedetectat. Iesire din program..."; echo " "; exit 1; fi
    set -e
    systemctl stop apache2 > /dev/null 2>&1
    echo " "
    echo "   >>>   C L O N R E A    A    I N C E P U T   <<<"
    echo " "
    echo "            ... aveti rabdare si asteptati..."
    echo " "
    PART_GUID_USB=$( (echo; echo o; echo Y; echo n; echo; echo; echo; echo; echo i; echo w; echo Y;) | gdisk /dev/sdb |grep "unique GUID" | cut -d":" -f2 | tr -d '[:space:]' )
    echo " "
    echo "   ... se formateaza noul stic USB... aveti rabdare si asteptati..."
    echo " "
    sleep 2
    echo y | mke2fs -t ext4 -L rootfs /dev/sdb1
    mkdir -p /media/stick/
    mount /dev/sdb1 /media/stick
    echo " "
    echo "   ... se copieaza sistemul pe noul stic USB... aveti rabdare si asteptati..."
    echo " "
    sleep 2
    rsync -axv / /media/stick
    UUID=$(tune2fs -l /dev/sdb1 |grep UUID | cut -d":" -f2 | sed 's/ //g')
    sed -i -E "s/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/${UUID}/g" /media/stick/etc/fstab
    umount -f /media/stick
    rm -fr /media/stick
    (echo; echo o; echo n; echo p; echo 1; echo 8192; echo 137215; echo t; echo c; echo n; echo p; echo 2; echo 137216; echo 2713599; echo p; echo w;) | fdisk /dev/sdc                       ### la fel cum e SD cardul existent
    echo " "
    echo "   ... se formateaza noul micro SD card... aveti rabdare si asteptati..."
    echo " "
    sleep 2
    echo y | mkfs.vfat -F32 -n boot /dev/sdc1
    echo y | mke2fs -t ext4 -L rootfs /dev/sdc2
    mkdir -p /media/sd/boot
    mkdir -p /media/sd/rootfs
    mount /dev/sdc1 /media/sd/boot
    mount /dev/sdc2 /media/sd/rootfs
    mkdir -p /mnt/sd_rootfs_ref
    mount /dev/mmcblk0p2 /mnt/sd_rootfs_ref
    echo " "
    echo "   ... se copieaza noul micro SD card... aveti rabdare si asteptati..."
    echo " "
    sleep 2
    rsync -axv /boot/ /media/sd/boot
    echo " "
    echo "   ... inca se copieaza noul micro SD card... aveti rabdare si asteptati..."
    echo " "
    sleep 2
    rsync -axv /mnt/sd_rootfs_ref/ /media/sd/rootfs
    sed -i -E "s/([A-Z0-9]{8}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{12})/${PART_GUID_USB}/g" /media/sd/boot/cmdline.txt 
    cp /media/sd/boot/cmdline.txt /media/sd/boot/cmdline.txt.partuuid
    umount -f /mnt/sd_rootfs_ref
    umount -f /media/sd/boot
    umount -f /media/sd/rootfs
    rm -fr /mnt/sd_rootfs_ref
    rm -fr /media/sd
    systemctl start apache2 > /dev/null 2>&1
    echo " "
    echo "  >>>   C L O N A R E A    S - A    T E R M I N A T   <<<"
    echo " "
    sleep 2
    echo "   Acum aparatul va fi oprit. Puteti sa scoateti noul stic USB si noul micro SD card si sa le introduceti in noul aparat clona"
    echo " "
    sleep 3
    /sbin/shutdown -h now
  else
    echo "   Iesire din program. Reluati cand sunteti gata..."
    echo " "
  fi
else
  echo "   Iesire din program. LA REVEDERE!"
  echo " "
fi
