#!/bin/bash
# Date: 07/02/2020
# Author: John
# This script copies the minecraft world folder to the map folder every hour.
# Use the start.sh script to launch the backup process, as start.sh calls this script in a new screen.
# Every new folder copied over overwrites the latest world copy.
# The script is configured to push a zipped file of the world folders, to the Middcraft/Map Github Repository.
# See https://github.com/MiddCraft/map

########################### FOLDER PATHS #######################################
# NOTE: Make sure to add a trailing slash / at the end of folder names.

# Destination folder for weekly backups
weeklybackupsdir="/root/map/"

# Server source folder (where the world file to be backed-up is located)
# This is typically the folder which contains your Minecraft .jar and all other server files.
sourcedir="/root/MiddCraft/"

# Name of source world folder (typically called "world" by default), as well as nether & end folders
worlddirname="world"
netherdirname="world_nether"
enddirname="world_the_end"

# End zip file name (include .zip at the end please)
zipname="middleburymap.zip"

# Commit message to be displayed on GitHub
commitmessage="Weekly map upload"

##############################################################################

# Source world folder path
worlddir="${sourcedir}${worlddirname}/"
netherdir="${sourcedir}${netherdirname}/"
enddir="${sourcedir}${enddirname}/"

echo "Starting up the weekly backup process..."
echo "The timezone used is UTC. Backups are saved to the $weeklybackupsdir folder every Monday."

format_backup () {
        cp -r ${worlddir} ${netherdir} ${enddir} ${weeklybackupsdir}
        destworlddir="${weeklybackupsdir}${worlddirname}"
        destnetherdir="${weeklybackupsdir}${netherdirname}"
        destenddir="${weeklybackupsdir}${enddirname}"

        cd ${destworlddir}
        rm -r advancements/ poi/ playerdata/ stats/ # Remove any user data

        cd ${weeklybackupsdir}
        zip -r ${zipname} ${destworlddir} ${netherdir} ${enddir}
}

while true; do
        
        currentweekday="$(date +%A)"

        if [ "$currentweekday" == "Monday" ]; then
                # Removes user data and creates the zip
                format_backup

                # Add the zip to git, commit & push
                git add ${weeklybackupsdir}${zipname}
                git commit -m ${commitmessage}
                git push

                sleep 24h
        fi

        # Check every hour to see if it's Monday yet
        sleep 1h
done
