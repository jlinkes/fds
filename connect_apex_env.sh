#!/bin/bash
if [[ $# -ne 1 ]]
then
    echo "Must have one argument which is the name of the alias to use to connect to jumphost"
    exit 1
fi
pod_alias=$1
#The passed argument is an array so capture it in a variable
orig_session_num=$(qdbus org.kde.konsole /Konsole currentSession)
ssh_command=`grep $pod_alias= ~/.bash_aliases | cut -d "=" -f 2 | cut -d "'" -f 2`
sessions=(`$ssh_command cat /root/.overcloud/node_list`)
session_count=${#sessions[*]}
nsessions=0
i=0

while [[ $i -lt $session_count ]]
do
    name=${sessions[$i]}
    let i++
    overcloud_node_ip_address=${sessions[$i]}
    let i++
    echo "Connecting to $name at $overcloud_node_ip_address on $pod_alias"

    session_num=`qdbus org.kde.konsole /Konsole newSession`
    sleep 0.1
    qdbus org.kde.konsole /Sessions/$session_num setTitle 0 $pod_alias-$name
    qdbus org.kde.konsole /Sessions/$session_num setTitle 1 $pod_alias-$name
    qdbus org.kde.konsole /Sessions/$session_num sendText "$pod_alias"$'\n'
    qdbus org.kde.konsole /Sessions/$session_num sendText \
        "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $overcloud_node_ip_address"$'\n'

    qdbus org.kde.konsole /Konsole moveSessionLeft
    let nsessions++
done
qdbus org.kde.konsole /Sessions/$orig_session_num setTitle 0 $pod_alias-jumphost
qdbus org.kde.konsole /Sessions/$orig_session_num setTitle 1 $pod_alias-jumphost
qdbus org.kde.konsole /Sessions/$orig_session_num sendText "$pod_alias"$'\n'

while [[ $nsessions -gt 0 ]]
do
    qdbus org.kde.konsole /Konsole prevSession
    let nsessions--
done
