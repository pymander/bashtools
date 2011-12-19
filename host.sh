#!/bin/bash
#
# Create a hostfile from the SSH key database which will allow tab
# completion with SSH commands.

knownhosts="$HOME/.ssh/known_hosts"
HOSTFILE=$HOME/bashtools/hostfile
DEFAULT_DOMAIN=leisurenouveau.com

# If our known_hosts file is older than our host file, just ignore it.
create_hostfile () {
    local entry
    local host
    
    cat /dev/null > $HOSTFILE
    for entry in $(cat $knownhosts | awk '{print $1}' | sort | uniq)
    do
        fullhost=$(echo $entry | awk -F , '{print $1}')
        ip=$(echo $entry | awk -F , '{print $2}')

        # Fill out our IP address.
        if [ "x$ip" == "x" ]
        then
            ip="0.0.0.0"
        fi

        case "$fullhost" in
            *.*)
                host=${fullhost//.*/}
                echo "${ip} ${fullhost} ${host}" >> $HOSTFILE
                ;;
            *)
                echo "${ip} ${host}.${DEFAULT_DOMAIN} ${host}" >> $HOSTFILE
                ;;
        esac
    done

    # Next we parse the $HOME/.ssh/config file and pull out host definitions.
    awk '/^host/ { print "0.0.0.0 " $2 " " $2 }' < $HOME/.ssh/config >> $HOSTFILE
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
