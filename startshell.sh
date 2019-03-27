#!/bin/bash
i=$1
/usr/sbin/sshd -e
sed -i 's/^$/+ : '$i' : ALL/' /etc/security/access.conf
echo "$i ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$i
sudo -H -u $i sh -c /bin/bash

