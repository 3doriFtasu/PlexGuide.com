#!/bin/bash
#source settings.conf
# functions:
# cat_Art() - init msg
# upload_Json() - configure with new jsons
# configure_json() - load jsons into rclone config
# init_DB() - validates gdsa's & init least usage DB

cat_Secret_Art(){
touch /opt/appdata/plexguide/.rclone
cat <<ART
[32m
                         __                    ___
  ___ __ _____  ___ ____/ /________ ____  ___ / _/__ ____ [35m2[32m
 (_-</ // / _ \/ -_) __/ __/ __/ _ \`/ _ \(_-</ _/ -_) __/
/___/\_,_/ .__/\__/_/  \__/_/  \_,_/_//_/___/_/ \__/_/
        /_/    [1;39;2mLoad Balanced Multi-SA Gdrive Uploader
[0m
┌────────────────────────────────────────────────────────┐
│ Version               :   Beta 2.1 Secret Edition      │
│ Author                :   Flicker-Rate                 │
│ Special Thanks        :   ddurdle                      │
│ —————————————————————————————————————————————————————— │
│ Bypass the 750GB/day limit on a single Gsuite account. │
│ [5;31m           ⚠ Loose Lips Might Sink Ships! ⚠[0m            │
│      Do your part and keep publicity to a minimum.     │
│     Don't talk about this method on public forums.     │
└────────────────────────────────────────────────────────┘
ART
}

cat_Art(){
cat <<ART
[0m
                         __                    ___
  ___ __ _____  ___ ____/ /________ ____  ___ / _/__ ____
 (_-</ // / _ \/ -_) __/ __/ __/ _ \`/ _ \(_-</ _/ -_) __/
/___/\_,_/ .__/\__/_/  \__/_/  \_,_/_//_/___/_/ \__/_/
        /_/           [1;39;2mRclone Configurator For Plexguide
[0m
┌────────────────────────────────────────────────────────┐
│ Version               :   Beta 2.1                     │
│ Author                :   Flicker-Rate                 │
└────────────────────────────────────────────────────────┘

ART
}

cat_Help(){
cat <<HELP
Usage: supertransfer [OPTION]

##############################
ATTN: Commands not ready yet!
##############################

-s, --status           bring up status menu (not ready)
-l, --logs             show program logs
-r, --restart          restart daemon
    --stop             stop daemon
    --start            start daemon

-c, --config           start configuration wizard
    --config-rclone    interactively configure gdrive service accounts
    --purge-rclone     remove all service accounts and reconfigure
    --set-email=EMAIL  config gdrive account impersonation
    --set-teamdrive=ID config teamdrive with ID (default: no)
    --set-path=PATH    config where files are stored on gdrive: (default: /)

    --pw=PASSWORD      unlocks secret multi-SA mode ;)
                       n00b deterrence:
                       password is reversed base64 of ZWxkcnVkCg==

-v  --validate         validates json account(s)
-V  --version          outputs version
-h, --help             what you're currently looking at

Please report any bugs to @flicker-rate#3637 on discord, or at plexguide.com
HELP
}

cat_Troubleshoot(){
read -p "View Troubleshooting Tips? y/n>" answer
if [[ $answer =~ [y|Y|yes|Yes] ]]; then
cat <<EOF
####### Troubleshooting steps: ###########################

1. Make sure you have enabled gdrive api access in
   both the dev console and admin security settings.

2. Check if the json keys have "domain wide delegation"

3. Check if the this email is correct:
   [1;35m$gdsaImpersonate[0m
      - if it is incorrect, configure it again with:
        supertransfer --config

4. Remove the offending keys and run:
        supertransfer --purge-rclone

5. Check these logs for detailed debugging:
      - /tmp/SA_error.log

##########################################################
EOF
fi

read -p "View Error Log? y/n>" answer
[[ $answer =~ [y|Y|yes|Yes] ]] && less /tmp/SA_error.log
}

upload_Json(){
source settings.conf
source usersettings.conf
[[ ! -e $jsonPath ]] && mkdir $jsonPath && log 'Json Path Not Found. Creating.' INFO && sleep 0.5
[[ ! -e $jsonPath ]] && log 'Json Path Could Not Be Created.' FAIL && sleep 0.5

localIP=$(curl -s icanhazip.com)
[[ -z $localIP ]] && localIP=$(wget -qO- http://ipecho.net/plain ; echo)
cd $jsonPath
python3 /opt/plexguide/scripts/supertransfer/jsonUpload.py &>/dev/null &
jobpid=$!
trap "kill $jobpid && exit 1" SIGTERM

cat <<MSG

############ CONFIGURATION ################################

1. Go to [32mhttp://${localIP}:8000[0m
2. Follow the instructions to generate the json keys
2. Upload 20-99 Gsuite service account json keys
3. Enter your gsuite email in the next step

Make sure you allow api access in the security settings
and check "enable domain wide delegation"

If port 8000 is closed or you wish to upload keys securely,
Transfer json keys directly into:
$jsonPath

###########################################################

MSG
read -rep $'\e[032m   -- Press any key when you are done uploading --\e[0m'
trap "exit 1" SIGTERM
echo
start_spinner "Terminating Web Server."
sleep 2
{ kill $jobpid && wait $jobpid; } &>/dev/null
stop_spinner $(( ! $? ))

if [[ $(ps -ef | grep "jsonUpload.py" | grep -v grep) ]]; then
  start_spinner "Web Server Still Running. Attempting to kill again."
	jobpid=$(ps -ef | grep "jsonUpload.py" | grep -v grep | awk '{print $2}')
	sleep 5
  { kill $jobpid && wait $jobpid; } &>/dev/null
  stop_spinner $(( ! $? ))
fi

numKeys=$(ls $jsonPath | egrep -c .json$)
if [[ $numKeys > 0 ]];then
   log "Found $numKeys Service Account Keys" INFO
    read -p 'Please Enter your Gsuite email: ' email
    [[ ! $email =~ .@. ]] && read -p 'Invalid email. Try Again: ' email
    [[ ! $email =~ .@. ]] && read -p 'Invalid email. Try Again: ' email
    [[ ! $email =~ .@. ]] && read -p 'Invalid email. Try Again: ' email
    sed -i '/'^gdsaImpersonate'=/ s/=.*/='$email'/' $usersettings
    source $usersettings
    [[ $gdsaImpersonate == $email ]] && log "Impersonation: $gdsaImpersonate" INFO || log "Failed To Update Settings" FAIL
else
   log "No Service Keys Found. Try Again." FAIL
   exit 1
fi
return 0
}


configure_Json(){
rclonePath=$(rclone -h | grep 'Config file. (default' | cut -f2 -d'"')
[[ ! $(ls $jsonPath | egrep .json$) ]] && log "No Service Accounts Json Found." FAIL && exit 1
# add rclone config for new keys if not already existing
for json in ${jsonPath}/*.json; do
  if [[ ! $(egrep  '^\[GDSA[0-9]+\]$' -A7 $rclonePath | grep $json) ]]; then
    oldMaxGdsa=$(egrep  '^\[GDSA[0-9]+\]$' $rclonePath | sed 's/\[GDSA//g;s/\]//' | sort -g | tail -1)
    newMaxGdsa=$((++oldMaxGdsa))
cat <<-CFG >> $rclonePath
[GDSA${newMaxGdsa}]
type = drive
client_id =
client_secret =
scope = drive
root_folder_id = $rootFolderId
service_account_file = $json
team_drive = $teamDrive
CFG
    ((++newGdsaCount))
  fi
done
[[ -n $newGdsaCount ]] && log "$newGdsaCount New Gdrive Service Account Added." INFO
return 0
}

# purge rclone of SA's
purge_Rclone(){
  rclonePath=$(rclone -h | grep 'Config file. (default' | cut -f2 -d'"')
  del=0
  while read line; do
    if [[ $line == '' ]]; then
    	del=0
    	echo $line >> ${rclonePath}.tmp
    elif [[ $del == 1 || $line =~ ^\[GDSA[0-9]+\]$ ]]; then
    	del=1
    else
    	del=0
    	echo $line >> ${rclonePath}.tmp
    fi
  done <$rclonePath
  cat ${rclonePath}.tmp > $rclonePath
  rm ${rclonePath}.tmp
  if [[ $(egrep '^\[GDSA[0-9]+\]$' -A7 $rclonePath) ]]; then
    log "Failed To Purge Rclone Config." WARN
  else
    log "Rclone Config Purge Successful." INFO
  fi
}
