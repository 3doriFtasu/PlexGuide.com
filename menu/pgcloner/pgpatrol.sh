#!/bin/bash
#
# Title:      PlexGuide (Reference Title File)
# Author(s):  Admin9705
# URL:        https://plexguide.com - http://github.plexguide.com
# GNU:        General Public License v3.0
################################################################################

### FILL OUT THIS AREA ###
echo 'pgpatrol' > /var/plexguide/pgcloner.rolename
echo 'PG Patrol' > /var/plexguide/pgcloner.roleproper
echo 'PlexGuide-PGPatrol' > /var/plexguide/pgcloner.projectname
echo 'v8.4' > /var/plexguide/pgcloner.projectversion

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo "💬 PG Vault is a combined group of services that utilizes the backup
and restore processes, which enables the safe storage and transport through
the use of Google Drive in a hasty and efficient manner!" > /var/plexguide/pgcloner.info
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### START PROCESS
bash /opt/plexguide/menu/pgcloner/core/main.sh
