#!/bin/bash
#
# Title:      PlexGuide (Reference Title File)
# Author(s):  Admin9705 - Deiteq
# URL:        https://plexguide.com - http://github.plexguide.com
# GNU:        General Public License v3.0
################################################################################
program=$(cat /tmp/program_var)
domain=$(cat /var/plexguide/server.domain)
port=$(cat /tmp/program_port)
ip=$(cat /var/plexguide/server.ip)

if [ "$program" == "plex" ]; then extra="/web"; else extra=""; fi

tee <<-EOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💎 Access Configuration Info > http://$program.plexguide.com
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF

file="/var/plexguide/server.ports"
  if [ -e "$file" ]; then
tee <<-EOF
▫ $ip:${port}${extra}
EOF
fi

if [ "$domain" != "NOT-SET" ]; then
  file="/var/plexguide/server.ports"
  if [ -e "$file" ]; then
tee <<-EOF
▫ $domain:${port}${extra}
EOF
  fi
tee <<-EOF
▫ $program.$domain${extra}
EOF
fi
