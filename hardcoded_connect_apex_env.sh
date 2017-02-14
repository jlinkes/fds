#!/bin/bash
function start_sessions()
{
    #The passed argument is an array so capture it in a variable
    pod_alias=$1
    local fds_sessions=(
        controller0         Shell        "$pod_alias"      192.168.10.16
        compute0            Shell        "$pod_alias"      192.168.10.15
        compute1            Shell        "$pod_alias"      192.168.10.14
    )
    local pirl_sessions=(
        controller0         Shell        "$pod_alias"      192.168.1.8
        compute0            Shell        "$pod_alias"      192.168.1.7
        compute1            Shell        "$pod_alias"      192.168.1.6
    )
    local cengn_sessions=(
        controller0         Shell        "$pod_alias"      10.120.0.11
        compute0            Shell        "$pod_alias"      10.120.0.10
        compute1            Shell        "$pod_alias"      10.120.0.4
    )
    # TODO add one session and also connect to docker
    sessions=( "${pirl_sessions[@]}" )
    local nsessions=0
    local session_count=${#sessions[*]}
    local i=0
    local orig_session_num=$(qdbus org.kde.konsole /Konsole currentSession)

    while [[ $i -lt $session_count ]]
    do
        local name=${sessions[$i]}
        let i++
        local profile=${sessions[$i]}
        let i++
        local command=${sessions[$i]}
        let i++
        local overcloud_node_ip_address=${sessions[$i]}
        let i++
        echo "Connecting to $name at $overcloud_node_ip_address on $pod_alias"

        # Starting with a specific profile appears to be broken.
        #local session_num=$(qdbus org.kde.konsole /Konsole newSession $profile $HOME)
        local session_num=$(qdbus org.kde.konsole /Konsole newSession)
        sleep 0.1
        qdbus org.kde.konsole /Sessions/$session_num setTitle 0 $pod_alias-$name
        qdbus org.kde.konsole /Sessions/$session_num setTitle 1 $pod_alias-$name
        qdbus org.kde.konsole /Sessions/$session_num sendText "$command"$'\n'
        qdbus org.kde.konsole /Sessions/$session_num sendText \
            "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $overcloud_node_ip_address"$'\n'

        qdbus org.kde.konsole /Konsole moveSessionLeft

        let nsessions++
    done
    qdbus org.kde.konsole /Sessions/$orig_session_num setTitle 0 $pod_alias-jumphost
    qdbus org.kde.konsole /Sessions/$orig_session_num setTitle 1 $pod_alias-jumphost
    qdbus org.kde.konsole /Sessions/$orig_session_num sendText "$command"$'\n'

     # Activate first session.
    while [[ $nsessions -gt 1 ]]
    do
        qdbus org.kde.konsole /Konsole prevSession
        let nsessions--
    done
}
if [[ $# -ne 1 ]]
then
    echo "Must have one argument which is the name of the alias to use to connect to jumphost"
    exit 1
fi
start_sessions $1

