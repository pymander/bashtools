#!/bin/bash
#
# Create a hostfile from the SSH key database which will allow tab
# completion with SSH commands.

knownhosts="$HOME/.ssh/known_hosts"
HOSTFILE=$HOME/.bash/hostfile

# If our known_hosts file is older than our host file, just ignore it.
create_hostfile () {
    local entry
    local host
    
    cat /dev/null > $HOSTFILE
    for entry in $(cat $knownhosts | awk '{print $1}' | sort | uniq)
    do
        entry=$(echo $entry | awk -F , '{print $1}')
        case "$entry" in
            *.musiciansfriend.com)
                host=${entry//.musiciansfriend.com/}
                echo "0.0.0.0 ${entry} ${host}" >> $HOSTFILE
                ;;
            *.*)
                #echo "Matched $entry"
                ;;
            *)
                echo "0.0.0.0 ${entry}.musiciansfriend.com ${entry}" >> $HOSTFILE
                ;;
        esac
    done
}

# Rebuild our hostfile, if needed.
for kh in $knownhosts
do
    if [ "$kh" -nt "$HOSTFILE" ]
    then
        echo -n "+ Recreating $HOSTFILE ... "
        create_hostfile
        echo "done"
        break
    fi
done

export HOSTFILE

# End of file!
