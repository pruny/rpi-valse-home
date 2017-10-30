#!/bin/bash


# http://unix.stackexchange.com/questions/12578/list-packages-by-installation-date

# looong line:

find /var/lib/dpkg/info -name "*.list" -exec stat -c $'%n\t%y' {} \; | sed -e 's,/var/lib/dpkg/info/,,' -e 's,\.list\t,\t,' | find /var/lib/dpkg/info -name "*.list" -exec stat -c $'%n\t%y' {} \; | sed -e 's,/var/lib/dpkg/info/,,' -e 's,\.list\t,\t,' | sort -r -k2.1,2.10 -k3.1,3.18 > ~/dpkglist_by_date_reverse_sort

# or multiple lines:

find /var/lib/dpkg/info -name "*.list" -exec stat -c $'%n\t%y' {} \; \
| sed -e 's,/var/lib/dpkg/info/,,' -e 's,\.list\t,\t,' \
| find /var/lib/dpkg/info -name "*.list" -exec stat -c $'%n\t%y' {} \; \
| sed -e 's,/var/lib/dpkg/info/,,' -e 's,\.list\t,\t,' \
| sort -r -k2.1,2.10 -k3.1,3.18 > /home/pi/data/shared/dpkglist_by_date_reverse_sort \
&& echo "" && echo "Done, check file \"/home/pi/data/shared/dpkglist_by_date_reverse_sort\""
