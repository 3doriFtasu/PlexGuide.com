#!/bin/bash
#
# Title:      PlexGuide (Reference Title File)
# Author(s):  Admin9705
# URL:        https://plexguide.com - http://github.plexguide.com
# GNU:        General Public License v3.0
################################################################################

# KEY VARIABLE RECALL & EXECUTION
mkdir -p /var/plexguide/pgtrakt

# FUNCTIONS START ##############################################################

# FIRST FUNCTION
variable () {
  file="$1"
  if [ ! -e "$file" ]; then echo "$2" > $1; fi
}

deploycheck () {
  dcheck=$(systemctl status pgtrakt | grep "\(running\)\>" | grep "\<since\>")
  if [ "$dcheck" != "" ]; then dstatus="✅ DEPLOYED";
else dstatus="⚠️ NOT DEPLOYED"; fi
}

plexcheck () {
  pcheck=$(docker ps | grep "\<plex\>")
  if [ "$pcheck" == "" ]; then

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔️  WARNING! - Plex is Not Installed or Running! Exiting!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
    read -p 'Confirm Info | PRESS [ENTER] ' typed < /dev/tty
    exit; fi
}

token () {
 touch /var/plexguide/plex.token
 ptoken=$(cat /var/plexguide/plex.token)
 if [ "$ptoken" == "" ]; then
   bash /opt/plexguide/menu/plex/token.sh
   ptoken=$(cat /var/plexguide/plex.token)
   if [ "$ptoken" == "" ]; then
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔️  WARNING! - Failed to Generate a Valid Plex Token! Exiting Deployment!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
    read -p 'Confirm Info | PRESS [ENTER] ' typed < /dev/tty
    exit; fi; fi
}

# BAD INPUT
badinput () {
echo
read -p '⛔️ ERROR - BAD INPUT! | PRESS [ENTER] ' typed < /dev/tty
question1
}

selection1 () {
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Instantly Kick Video Transcodes?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ Reference: http://pgtrakt.plexguide.com

1 - False
2 - True

EOF
  read -p 'Type Number | PRESS [ENTER] ' typed < /dev/tty
    if [ "$typed" == "1" ]; then echo "False" > /var/plexguide/pgtrakt/video.transcodes && question1;
  elif [ "$typed" == "2" ]; then echo "True" > /var/plexguide/pgtrakt/video.transcodes && question1;
    else badinput; fi
}

selection2 () {
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Limit Amount of Different IPs a User Can Make?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ Reference: http://pgtrakt.plexguide.com

Set a Number from 1 - 99

EOF
  read -p 'Type Number | PRESS [ENTER] ' typed < /dev/tty
    if [[ "$typed" -ge "1" && "$typed" -le "99" ]]; then echo "$typed" > /var/plexguide/pgtrakt/multiple.ips && question1;
    else badinput; fi
}

selection3 () {
tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Limit How Long a User Can Pause For!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ Reference: http://pgtrakt.plexguide.com

Set a Number from 5 - 999 Mintues

EOF
  read -p 'Type Number | PRESS [ENTER] ' typed < /dev/tty
    if [[ "$typed" -ge "1" && "$typed" -le "999" ]]; then echo "$typed" > /var/plexguide/pgtrakt/kick.minutes && question1;
    else badinput; fi
}

# FIRST QUESTION
question1 () {

video=$(cat /var/plexguide/pgtrakt/video.transcodes)
ips=$(cat /var/plexguide/pgtrakt/multiple.ips)
minutes=$(cat /var/plexguide/pgtrakt/kick.minutes)

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 PG Patrol Interface
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ Reference: http://pgtrakt.plexguide.com

1 - Instantly Kick Video Transcodes?   [$video]
2 - UserName | Multiple IPs?           [$ips]
3 - Minutes  | Kick Paused Transcode?  [$minutes]
4 - Deploy PGTrakt                     [$dstatus]
Z - EXIT

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

  read -p '↘️  Type Number | Press [ENTER]: ' typed < /dev/tty

  if [ "$typed" == "1" ]; then selection1;
elif [ "$typed" == "2" ]; then selection2;
elif [ "$typed" == "3" ]; then selection3;
elif [ "$typed" == "4" ]; then ansible-playbook /opt/plexguide/menu/pgtrakt/pgtrakt.yml && question1;
elif [[ "$typed" == "Z" || "$typed" == "z" ]]; then exit;
else badinput; fi
}

# FUNCTIONS END ##############################################################
plexcheck
token
variable /var/plexguide/pgtrakt/video.transcodes "False"
variable /var/plexguide/pgtrakt/multiple.ips "2"
variable /var/plexguide/pgtrakt/kick.minutes "1"
deploycheck
question1
