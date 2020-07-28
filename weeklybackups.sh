#!/bin/bash
# Date: 07/02/2020
# Author: John
# This script copies the minecraft world folder to the map folder once a week, on Monday.
# Use the start.sh script to launch the backup process, as start.sh calls this script in a new screen.
# Every new folder copied over overwrites the latest world copy.
# The weekly backed up folder may be found publicly at https://github.com/MiddCraft/map

########################### FILE PATHS #######################################
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

# Commit message to be displayed on GitHub
commitmessage="Weekly map upload"

##############################################################################

# Source world folder path (where the Minecraft server files are located)
worlddir="${sourcedir}${worlddirname}/"
netherdir="${sourcedir}${netherdirname}/"
enddir="${sourcedir}${enddirname}/"

destworlddir="${weeklybackupsdir}${worlddirname}"
destnetherdir="${weeklybackupsdir}${netherdirname}"
destenddir="${weeklybackupsdir}${enddirname}"

echo "Starting up the weekly backup process..."
echo "The timezone used is UTC. Backups are saved to the $weeklybackupsdir folder every Monday."

import_backups () {
        # Copy in the world folders to the destination directory
        cp -r ${worlddir} ${netherdir} ${enddir} ${weeklybackupsdir}

        cd ${destworlddir}
        rm -r advancements/ playerdata/ stats/ # Remove any user data that should not be uploaded
}

while true; do
        currentweekday="$(date +%A)"

        if [ "$currentweekday" == "Tuesday" ]; then
                # Removes user data from world files & copies the world backups over
                import_backups

                # This will not re-add files already existing or unmodified in
                # git (e.g the README.md file), however it will delete any
                # locally removed files
                git commit -a -m ${commitmessage}

                git push

                sleep 24h
        fi

        # Check every hour to see if it's Monday yet
        sleep 1h
done
