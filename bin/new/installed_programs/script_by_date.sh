#!/bin/bash


# http://unix.stackexchange.com/questions/12578/list-packages-by-installation-date
find /var/lib/dpkg/info -name "*.list" -exec stat -c $'%n\t%y' {} \; | sed -e 's,/var/lib/dpkg/info/,,' -e 's,\.list\t,\t,' | find /var/lib/dpkg/info -name "*.list" -exec stat -c $'%n\t%y' {} \; | sed -e 's,/var/lib/dpkg/info/,,' -e 's,\.list\t,\t,' | sort > ~/dpkglist_by_dates
