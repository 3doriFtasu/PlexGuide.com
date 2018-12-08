#!/bin/bash
#
# Title:      PGClone (A 100% PG Product)
# Author(s):  Admin9705
# URL:        https://plexguide.com - http://github.plexguide.com
# GNU:        General Public License v3.0
################################################################################
source /opt/plexguide/menu/functions/functions.sh
source /opt/plexguide/menu/functions/keys.sh
source /opt/plexguide/menu/functions/keyback.sh
source /opt/plexguide/menu/functions/pgclone.sh
################################################################################
question1 () {
  touch /opt/appdata/plexguide/rclone.conf
  transport=$(cat /var/plexguide/pgclone.transport)
  gstatus=$(cat /var/plexguide/gdrive.pgclone)
  tstatus=$(cat /var/plexguide/tdrive.pgclone)
  transportdisplay

if [ "$transport" == "NOT-SET" ]; then
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💪 Welcome to PG Clone                 📓 Reference: pgclone.plexguide.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1] Data Transport Mode: $transport
[Z] Exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
read -p '↘️  Type Selection | Press [ENTER]: ' typed < /dev/tty

  if [ "$typed" == "1" ]; then
  transportmode
  question1
elif [[ "$typed" == "Z" || "$typed" == "z" ]]; then exit; fi
fi

if [[ "$transport" == "PG Move /w No Encryption" || "$transport" == "PG Move /w Encryption" ]]; then menufix=1; else menufix=2; fi

if [ "$menufix" == "1" ]; then
bwdisplay=$(cat /var/plexguide/move.bw)
display1="[3] Throttle Limit:      $bwdisplay MB
[4] Deploy:              $transport"
a=9999999; fi
if [ "$menufix" == "2" ]; then
mkdir -p /opt/appdata/pgblitz/keys/processed/
keynum=$(ls /opt/appdata/pgblitz/keys/processed/ | wc -l)
display1="[3] Key Management:      $keynum Keys Deployed
[4] Deploy:              $transport"

a=4; fi

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💪 Welcome to PG Clone                 📓 Reference: pgclone.plexguide.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1] Data Transport Mode: $transport
[2] OAuth & Mounts
$display1
[Z] Exit

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
read -p '↘️  Type Selection | Press [ENTER]: ' typed < /dev/tty

  if [ "$menufix" == "2" ]; then
    if [ "$typed" == "3" ]; then
      keymenu
      question1
    elif [ "$typed" == "4" ]; then
      blitzchecker
      removemounts
      ufsbuilder
      ansible-playbook /opt/plexguide/menu/pgclone/gdrive.yml
      ansible-playbook /opt/plexguide/menu/pgclone/tdrive.yml
      ansible-playbook /opt/plexguide/menu/pgclone/bunionfs.yml
      ansible-playbook /opt/plexguide/menu/pgclone/pgblitz.yml
      ansible-playbook /opt/plexguide/containers/blitzui.yml
      pgbdeploy
      question1
    fi
  fi

  if [ "$typed" == "1" ]; then
  transportmode
  question1
elif [ "$typed" == "2" ]; then
  mountsmenu
  question1
elif [ "$typed" == "3" ]; then
  if [ "$menufix" == "1" ]; then
    bandwidth
    question1
  fi
elif [ "$typed" == "4" ]; then
  if [ "$menufix" == "1" ]; then
    if [ "$transport" == "PG Move /w No Encryption" ]; then
      mkdir -p /var/plexguide/rclone/
      echo "gdrive" > /var/plexguide/rclone/deploy.version
      removemounts
      ansible-playbook /opt/plexguide/menu/pgclone/gdrive.yml
      ansible-playbook /opt/plexguide/menu/pgclone/munionfs.yml
      ansible-playbook /opt/plexguide/menu/pgclone/pgmove.yml
      question1
    fi
    if [ "$transport" == "PG Move /w Encryption" ]; then
      mkdir -p /var/plexguide/rclone/
      echo "gcrypt" > /var/plexguide/rclone/deploy.version
      deploygcryptcheck
      removemounts
      ansible-playbook /opt/plexguide/menu/pgclone/gdrive.yml
      ansible-playbook /opt/plexguide/menu/pgclone/gcrypt.yml
      ansible-playbook /opt/plexguide/menu/pgclone/munionfs.yml
      ansible-playbook /opt/plexguide/menu/pgclone/pgmove.yml
      question1
    fi
  else
  question1
  fi
elif [ "$typed" == "$a" ]; then
  question1
elif [[ "$typed" == "Z" || "$typed" == "z" ]]; then
  exit
else
  badinput
  question1; fi
#menu later
inputphase
}
# Reminder for gdrive/tdrive / check rclone to set if active, below just placeholder
variable /var/plexguide/project.account "NOT-SET"
variable /var/plexguide/pgclone.project "NOT-SET"
variable /var/plexguide/pgclone.teamdrive ""
variable /var/plexguide/pgclone.public ""
variable /var/plexguide/pgclone.secret ""
variable /var/plexguide/pgclone.transport "PG Move /w No Encryption"
variable /var/plexguide/gdrive.pgclone "⚠️  Not Activated"
variable /var/plexguide/tdrive.pgclone "⚠️  Not Activated"
variable /var/plexguide/move.bw  "10"

question1
