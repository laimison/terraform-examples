#!/bin/bash

# App account
useradd app -s /bin/bash

# Some Packages
yum install -y lsof python36 firewalld nc httpd

# Start HTTP service
# A bit messy, but added just for the test

# mkdir -p /tmp/http
# cd /tmp/http && nohup python3 -m http.server -b 0.0.0.0 8080 &
# nohup busybox httpd -f -p 8080 &

echo "Apache server `hostname` reached!" > /usr/share/httpd/noindex/index.html

sed -i "s|^Listen 80$|Listen 8080|g" /etc/httpd/conf/httpd.conf

systemctl start httpd
systemctl enable httpd

# Firewall
sleep 5
# systemctl start firewalld
# systemctl enable firewalld
systemctl stop firewalld
systemctl disable firewalld

# firewall-cmd --zone=public --add-port=8080/tcp --permanent
# firewall-cmd --reload

# selinux stuff
setenforce 0
sed -i -e "s/^SELINUX.*$/SELINUX=disabled/" /etc/selinux/config
# shutdown -r now

# Wait until internal storage is provisioned
for i in `seq 1 60`
do
  if lsblk | grep xvdh
  then
    # Internal Storage
    file -s /dev/xvdh | grep ': data$' && mkfs -t ext4 /dev/xvdh
    mkdir /app
    mount /dev/xvdh /app
    echo /dev/xvdh  /app ext4 defaults,nofail 0 2 | tee -a /etc/fstab
    chown -R app:app /app

    break
  fi

  sleep 5
done

# Wait until external storage is provisioned
for i in `seq 1 60`
do
  rpm -qa | grep ^bind-utils- || yum install -y bind-utils

  if host ${some_address} 2>/dev/null | grep -v ' not ' | grep ' address '
  then
    # External Storage
    yum install -y nfs-utils
    mkdir -p /nfs
    mount -t nfs4 ${some_address}:/ /nfs
    chown -R app:app /nfs

    break
  fi

  sleep 5
done

touch /tmp/ec2-init-script-finished
