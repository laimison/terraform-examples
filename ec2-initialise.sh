#!/bin/bash

# Wait until storage is provisioned
while true
do
  rpm -qa | grep ^bind-utils- || yum install -y bind-utils

  if lsblk | grep xvdh && host ${some_address} | grep -v ' not ' | grep ' address '
  then
    break
  fi

  sleep 5
done

# App account
useradd app -s /bin/bash

# Internal Storage
file -s /dev/xvdh | grep ': data$' && mkfs -t ext4 /dev/xvdh
mkdir /app
mount /dev/xvdh /app
echo /dev/xvdh  /app ext4 defaults,nofail 0 2 | tee -a /etc/fstab
chown -R app:app /app

# External Storage
yum install -y nfs-utils
mkdir -p /nfs
mount -t nfs4 ${some_address}:/ /nfs
chown -R app:app /nfs

# Start sample service
mkdir /tmp/http
cd /tmp/http
echo "Server is running" > /tmp/http/index.html
python3 -m http.server -b 0.0.0.0 8080 &
