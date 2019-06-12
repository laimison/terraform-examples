#!/bin/bash
mkfs -t ext4 /dev/xvdh
mkdir /app
mount /dev/xvdh /app
echo /dev/xvdh  /app ext4 defaults,nofail 0 2 | tee -a /etc/fstab
useradd app -s /bin/bash
chown -R app:app /app
