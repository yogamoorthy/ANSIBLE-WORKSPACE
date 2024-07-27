#!/bin/sh
#=====================================================================#
# Script name:  purgeWMIntegration.sh
# Parameters:                                                         #
# $1: $Parent Path to files
# $2: Number of days to purge.                                        #
#=====================================================================#

parentPath=$1
numDays=$2

#paths to look for old files
declare -a arr=("${parentPath}/working"
        "${parentPath}/archive"
        "${parentPath}/error")


echo  "************* Script purgeWMIntegration starting" $(date) "*************"

for i in "${arr[@]}"
do
        if [ -d ${i} ]; then
                echo " Removing old ${i} files"
                cd "$i"
                #echo "${PWD}"
                find . -type f -mtime +${numDays} -exec rm -f {} \;
        else
                echo " Error in file path.  ${i} does not exist"
        fi
done

echo "*************** Script purgeWMIntegration ending ****************"
echo "*****************************************************************"
exit 0;
