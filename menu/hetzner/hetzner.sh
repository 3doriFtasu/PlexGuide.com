#!/usr/bin/env python3
#
# GitHub:   https://github.com/Admin9705/PlexGuide.com-The-Awesome-Plex-Server
# Author:   Admin9705
# URL:      https://plexguide.com
#
# PlexGuide Copyright (C) 2018 PlexGuide.com
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
#################################################################################

# Menu Interface
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 PG - Hetzner's Cloud Generator
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1 - Deploy a New Server
2 - List Server(s)
5 - Destory a Server
Z - Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

  read -p 'Type a Number | Press [ENTER]: ' typed < /dev/tty

if [ "$typed" == "1" ]; then
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 PG - Hetzner's Cloud OS Selector
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1 - Ubuntu 18.04 (PlexGuide Works)
2 - Ubuntu 16.04 (PlexGuide Works)
3 - Debian 9
4 - Centos 7
5 - Fendora 28
6 - Fendora 27
Z - Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

  read -p 'Type a Number | Press [ENTER]: ' typed < /dev/tty

  if [ "$typed" == "1" ]; then os="ubuntu-18.04";
elif [ "$typed" == "2" ]; then os="ubuntu-16.04";
elif [ "$typed" == "3" ]; then os="debian-9";
elif [ "$typed" == "4" ]; then os="centos-7";
elif [ "$typed" == "5" ]; then os="fendora-28";
elif [ "$typed" == "6" ]; then os="fendora-27";
elif [ "$typed" == "Z" ] || [ "$typed" == "z" ]; then exit;
  fi

  mkdir -p /opt/appdata/hetzner/$typed
  ssh-keygen -t rsa -b 4096 -C "$typed@plexguide.com" -f /opt/appdata/hetzner/$typed/$typed
  hcloud ssh-key create --name $typed --public-key-from-file /opt/appdata/hetzner/$typed/$typed.pub
  hcloud server create --name $typed --type cx11 --image ubuntu-18.04 --ssh-key $typed

elif [ "$typed" == "2" ]; then
  echo gce > /var/plexguide/type.choice && bash /opt/plexguide/menu/core/scripts/main.sh
elif [ "$typed" == "3" ]; then
  read -p 'Type the Name of a NEW SERVER | Press [ENTER]: ' typed < /dev/tty
  mkdir -p /var/plexguide/hetzner
  hcloud server create --name $typed --image ubuntu-18.04 --type cx11 > /var/plexguide/hetzner/hetzner.info
  cat "/var/plexguide/hetzner/hetzner.info" | grep IPv4: | cut -d' ' -f2- > /var/plexguide/hetzner/$typed.ip
  cat "/var/plexguide/hetzner/hetzner.info" | grep Root | cut -d' ' -f3- > /var/plexguide/hetzner/$typed.pw
  ipv4=$(cat /var/plexguide/hetzner/$typed.ip)
  pw=$(cat /var/plexguide/hetzner/$typed.pw)

wait 20 sec
ssh-keygen -f "/root/.ssh/known_hosts" -R "ipv4"

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Deployed Server $typed - $ipv4
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
read -p 'Press [ENTER] to Continue! ' typed < /dev/tty
echo



elif [ "$typed" == "4" ]; then
  bash /opt/plexguide/roles/menu-appguard/scripts/main.sh
elif [ "$typed" == "5" ]; then
  bash /opt/plexguide/menu/interface/pgtrak/main.sh
elif [ "$typed" == "Z" ] || [ "$typed" == "z" ]; then
  exit
else
  bash /opt/plexguide/menu/hetzner/hetzner.sh
  exit
fi

#⛔️  WARNING! - Must Configure RClone First /w >>> gdrive
# read -n 1 -s -r -p "Press [ANY] Key to Continue "
