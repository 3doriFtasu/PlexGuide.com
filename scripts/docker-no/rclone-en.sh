#!/bin/bash

clear

## Supporting Folders
#mkdir -p /mnt/move
mkdir -p /mnt/.gcrypt
#mkdir -p /mnt/gdrive
#mkdir -p /mnt/unionfs/tv
#mkdir -p /mnt/unionfs/movies
#mkdir -p /opt/appdata/plexguide
#mkdir -p /mnt/plexdrive4
mkdir -p /mnt/encrypt

## Installing rclone
  cd /tmp
  curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip 1>/dev/null 2>&1
  unzip rclone-current-linux-amd64.zip 1>/dev/null 2>&1
  cd rclone-*-linux-amd64
  cp rclone /usr/bin/ 1>/dev/null 2>&1
  chown 1000:1000 /usr/bin/rclone 1>/dev/null 2>&1
  chmod 755 /usr/bin/rclone 1>/dev/null 2>&1
  mkdir -p /usr/local/share/man/ 1>/dev/null 2>&1
  cp rclone.1 /usr/local/share/man/man1/ 1>/dev/null 2>&1
  mandb 1>/dev/null 2>&1
  cd .. && sudo rm -r rclone* 1>/dev/null 2>&1
  cd ~

############################################# RCLONE
## Excutes the RClone Config
rclone config

## RClone - Replace Fuse by removing the # from user_allow_other
tee "/etc/fuse.conf" > /dev/null <<EOF
  # /etc/fuse.conf - Configuration file for Filesystem in Userspace (FUSE)

  # Set the maximum number of FUSE mounts allowed to non-root users.
  # The default is 1000.
  #mount_max = 1000

  # Allow non-root users to specify the allow_other or allow_root mount options.
  user_allow_other
EOF

mkdir -p /root/.config/rclone/ 1>/dev/null 2>&1

## Copying to /mnt incase
cp ~/.config/rclone/rclone.conf /root/.config/rclone/ 1>/dev/null 2>&1

#chown -R 1000:1000 /mnt/encrypt  1>/dev/null 2>&1
#chmod 777 -R 1000:1000 /mnt/encrypt  1>/dev/null 2>&1

#chown -R 1000:1000 /mnt/.gcrypt  1>/dev/null 2>&1
#chmod 777 -R 1000:1000 /mnt/.gcrypt  1>/dev/null 2>&1
echo 1
## RClone Script
tee "/opt/appdata/plexguide/rclone.sh" > /dev/null <<EOF
#!/bin/bash
rclone --allow-non-empty --allow-other mount gdrive: /mnt/gdrive --bwlimit 8650k --size-only
EOF
chmod 755 /opt/appdata/plexguide/rclone.sh
echo 2
## RClone Server
tee "/etc/systemd/system/rclone.service" > /dev/null <<EOF
[Unit]
Description=RClone Daemon
After=multi-user.target
[Service]
Type=simple
User=0
Group=0
ExecStart=/bin/bash /opt/appdata/plexguide/rclone.sh
TimeoutStopSec=20
KillMode=process
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
echo 3
## RClone Script
tee "/opt/appdata/plexguide/rclone-encrypt.sh" > /dev/null <<EOF
#!/bin/bash
rclone --allow-non-empty --allow-other mount gcrypt: /mnt/.gcrypt --bwlimit 8650k --size-only
EOF
chmod 755 /opt/appdata/plexguide/rclone-encrypt.sh

## RClone Server
tee "/etc/systemd/system/rclone-encrypt.service" > /dev/null <<EOF
[Unit]
Description=RClone Daemon
After=multi-user.target
[Service]
Type=simple
User=0
Group=0
ExecStart=/bin/bash /opt/appdata/plexguide/rclone-encrypt.sh
TimeoutStopSec=20
KillMode=process
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
####################################### Encrypted Service
echo 4
## RClone Script
tee "/opt/appdata/plexguide/rclone-en.sh" > /dev/null <<EOF
#!/bin/bash
rclone --allow-non-empty --allow-other mount crypt: /mnt/encrypt --bwlimit 8650k --size-only
EOF
chmod 755 /opt/appdata/plexguide/rclone-en.sh
## Create the RClone service for plexdrive4 encrypted mount point
tee "/etc/systemd/system/rclone-en.service" > /dev/null <<EOF
[Unit]
Description=RClone Daemon
After=multi-user.target

[Service]
Type=simple
User=0
Group=0
ExecStart=/bin/bash /opt/appdata/plexguide/rclone-en.sh
TimeoutStopSec=20
KillMode=process
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
echo 5
#### Create the RClone Service for a direct gdrive encrypted mount point
##tee "/etc/systemd/system/rclone-encrypt.service" > /dev/null <<EOF
##[Unit]
##Description=RClone Daemon
##After=multi-user.target

##[Service]
##Type=simple
##User=plexguide
##Group=1000
##ExecStart=/usr/bin/rclone --allow-non-empty --allow-other mount gcrypt: /mnt/.gcrypt --bwlimit 8650k --size-only
##TimeoutStopSec=20
##KillMode=process
##RemainAfterExit=yes

##[Install]
##WantedBy=multi-user.target
##EOF

## Create the UnionFS Service for the plexdrive encrypted mount point
tee "/etc/systemd/system/unionfs-encrypt.service" > /dev/null <<EOF
[Unit]
Description=UnionFS Daemon
After=multi-user.target
[Service]
Type=simple
User=0
Group=0
ExecStart=/usr/bin/unionfs -o cow,allow_other,nonempty /mnt/move=RW:/mnt/encrypt=RO /mnt/unionfs
TimeoutStopSec=20
KillMode=process
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
echo 6
## Create the Encrypted Move Script
tee "/opt/appdata/plexguide/move-en.sh" > /dev/null <<EOF
#!/bin/bash
sleep 30
while true
do
rclone move --bwlimit 9M --tpslimit 4 --max-size 99G --log-level INFO --stats 15s /mnt/move gcrypt:/
sleep 900
done
EOF
chmod 755 /opt/appdata/plexguide/move-en.sh

## Create the Encrypted Move Service
tee "/etc/systemd/system/move-en.service" > /dev/null <<EOF
[Unit]
Description=Move Service Daemon
After=multi-user.target

[Service]
Type=simple
User=1000
Group=1000
ExecStart=/bin/bash /opt/appdata/plexguide/move-en.sh
TimeoutStopSec=20
KillMode=process
RemainAfterExit=yes
Restart=always

[Install]
WantedBy=multi-user.target
EOF
echo 7
###### Ensure Changes Are Reflected
sudo systemctl daemon-reload

#stop unencrypted services
systemctl stop rclone 1>/dev/null 2>&1
systemctl stop move 1>/dev/null 2>&1
systemctl stop unionfs 1>/dev/null 2>&1
systemctl disable rclone 1>/dev/null 2>&1
systemctl disable move 1>/dev/null 2>&1
systemctl disable unionfs 1>/dev/null 2>&1
echo 8
# ensure that the unencrypted services are on
systemctl enable rclone 1>/dev/null 2>&1
systemctl enable rclone-en 1>/dev/null 2>&1
systemctl enable move-en 1>/dev/null 2>&1
systemctl enable unionfs-encrypt 1>/dev/null 2>&1
systemctl enable rclone-encrypt 1>/dev/null 2>&1
systemctl start unionfs-encrypt 1>/dev/null 2>&1
systemctl start rclone 1>/dev/null 2>&1
systemctl start rclone-en 1>/dev/null 2>&1
systemctl start rclone-encrypt 1>/dev/null 2>&1
systemctl start move-en 1>/dev/null 2>&1

echo 9
systemctl restart rclone 1>/dev/null 2>&1
systemctl restart rclone-encrypt 1>/dev/null 2>&1
systemctl restart rclone-en 1>/dev/null 2>&1

# set variable to remember what version of rclone user installed
mkdir -p /var/plexguide/rclone 1>/dev/null 2>&1
touch /var/plexguide/rclone/en 1>/dev/null 2>&1
rm -r /var/plexguide/rclone/un 1>/dev/null 2>&1
echo 10
# pauses
bash /opt/plexguide/scripts/docker-no/continue.sh
echo 11
# sets a message
clear
cat << EOF
NOTE: You installed the encrypted version for the RClone data transport!
If you messed anything up, select [2] and run through again.
EOF

bash /opt/plexguide/scripts/docker-no/continue.sh
