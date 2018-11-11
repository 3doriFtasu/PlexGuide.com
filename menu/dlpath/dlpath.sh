#!/bin/bash
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

# Create Variables (If New) & Recall
variable () {
  file="$1"
  if [ ! -e "$file" ]; then echo "$2" > $1; fi
}

# For ZipLocations

variable /var/plexguide/server.hd.path "/mnt"
pgpath=$(cat /var/plexguide/server.hd.path)

used=$(df -h $pgpath | tail -n +2 | awk '{print $3}')
capacity=$(df -h $pgpath | tail -n +2 | awk '{print $2}')
percentage=$(df -h $pgpath | tail -n +2 | awk '{print $5}')
###################### FOR VARIABLS ROLE SO DOESNT CREATE RED - START

# Menu Interface
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌎  PG Processing Disk Interface
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌵  Processing Disk : $pgpath
    Processing Space: $used of $capacity | $percentage Used Capacity

☑️   PG does not format your second disk, nor mount it! We can
only assist by changing the location path!

☑️   Enables PG System to process items on a SECONDARY Drive rather
than tax the PRIMARY DRIVE. Like Windows, you can have your items
process on a (D): Drive instead of on a (C): Drive.

Do You Want To Change the Processing Disk?

[1] No
[2] Yes

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
# Standby
read -p '↘️   Type a Number | Press [ENTER]: ' typed < /dev/tty

  if [ "$typed" == "1" ]; then
    exit
elif [ "$typed" == "2" ]; then
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🍖  NOM NOM: Selected to Change the Processing Path
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🌵  Current Processing Disk : $pgpath

☑️   Type the path as show in the examples below! PG will then attempt
to see if your path exists!

Examples:
(1) /mnt/mymedia   (2) /secondhd/media   (3) /myhd/storage/media

⚠️   Stop the Process by Typing >>> exit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

# Standby
read -p '↘️   Type the NEW PATH (Follow Above Examples): ' typed < /dev/tty

# SubQuestion About Continuing
  if [ "$typed" == "exit" ]; then
    exit
  fi

# Checking Input
typed2=$typed
bonehead=no
##### If BONEHEAD forgot to add a / in the beginning, we fix for them
initial="$(echo $typed | head -c 1)"
if [ "$initial" != "/" ]; then
  typed="/$typed"
  bonehead=yes
fi
##### If BONEHEAD added a / at the end, we fix for them
initial="${typed: -1}"
if [ "$initial" == "/" ]; then
  typed=${typed::-1}
  bonehead=yes
fi

# Telling Them They Are a BoneHead
  if [ "$bonehead" == "yes" ]; then
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛑  BONEHEAD:  We Fixed the Path For You... (read next time)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

You Typed : $typed2
Changed To: $typed

EOF
sleep 3
  else
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅️ WOOT WOOT: The Input Valid!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 3
  fi

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🍖  NOM NOM: Checking the Processing Path's Existance
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

sleep 2

mkdir $typed/test 1>/dev/null 2>&1

file="$typed/test"
  if [ -e "$file" ]; then

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅️   WOOT WOOT: Location Is Valid - $typed
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⌛  STANDBY: Setting Up Your Permissions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2

chown 1000:1000 "$typed"
chmod 0775 "$typed"
rm -rf "$typed/test"
echo $typed > /var/plexguide/server.hd.path
break=off

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⌛  STANDBY: Rebuilding the Systems Docker Containers!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2

bash /opt/plexguide/menu/dlpath/rebuild.sh

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅️   WOOT WOOT: Process Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 2
  fi
else
# Repeats If User Fails to Answer Primary Question Correctly
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🍖  NOM NOM: Failed to Make a Valid Selection! Restarting the Process!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
sleep 3
bash /opt/plexguide/menu/dlpath/dlpath.sh
exit
fi

bash /opt/plexguide/menu/dlpath/dlpath.sh
exit
