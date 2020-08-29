#!/bin/bash
echo "audris:x:1000:1000:Audris Mockus,,,:/home/audris:/bin/bash" >> /etc/passwd
echo 'audris ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/audris
chmod 0440 /etc/sudoers.d/audris
sed -i 's/^$/+ : '' : ALL/' /etc/security/access.conf
sudo -H -u audris sh -c /bin/bash
