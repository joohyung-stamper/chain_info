#!/usr/bin/env bash

# input your .profile and source .profile again
# alias fh='bash ${HOME}/ssh-config/tools/find.sh'


if test $# -lt 1
then
        echo "./find_hnm.sh <host_name> or <ip_address>"
        exit 0
fi

function getHost()
{
	base_cmd="grep -h \"^[^#]\" ${HOME}/.ssh/config.d/* | grep -v IdentityFile | grep -v User "
	case $1 in
		[0-9][0-9]*\.[0-9][0-9]*\.*)
			base_cmd+="| grep -i -B1 $1 "
			;;
		[a-zA-Z][a-zA-Z]*) # search from host
			base_cmd+="| grep -i $1	"	
			;;
		*)
			base_cmd+="| grep -i -A3 -B1 $1 "
			;;
	esac
	base_cmd+="| grep -v \"\-\-\" | grep \"\S\" | grep -w \"Host\"" 
}

function printLine()
{
	echo "$base_cmd | grep -n \"\"" | sh
}

function setHost()
{
	cmd="$base_cmd | sed -n '"$input_num"'p"
}

function getHostInfo() {
    local host_info=$(pbpaste)
    local host=$(echo "$host_info" | grep -o 'Host .*' | cut -d ' ' -f 2)
    local host_section=$(grep -A3 "Host $host" "${HOME}/.ssh/config.d/"*)
    local host_name=$(echo "$host_section" | grep -o 'HostName .*' | cut -d ' ' -f 2)
    local user_name=$(echo "$host_section" | grep -o 'User .*' | cut -d ' ' -f 2)
    local port=$(echo "$host_section" | grep -o 'Port .*' | cut -d ' ' -f 2)
    
    if [ -n "$port" ]; then
        remote_addr="$host_name:$port"
    else
        remote_addr="$host_name"
    fi

    remote_user="$user_name"

	echo "Host Address: $remote_addr"
	echo "Host User: $remote_user"
}

function setHostInfo() {
    CONFIG_DIR="$(dirname "$(realpath "$0")")"

    # config.env 파일에 내용 추가
    echo "REMOTE_ADDR=$remote_addr" > "$CONFIG_DIR/config.env"
    echo "REMOTE_USER=$remote_user" >> "$CONFIG_DIR/config.env"
}

getHost $1

clear
echo "===================================================================================================="
echo $base_cmd | sh | sed 's/Host /ssh /'
echo "===================================================================================================="
read -p "show line number ?" enter
if [[ ! -z "$enter" ]]; then
	exit 0
fi
clear
printLine 
read -p "- Select a number of host which you want: " input_num
setHost
echo $cmd | sh | pbcopy
pbpaste
getHostInfo
setHostInfo