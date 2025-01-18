#!/bin/bash

#SERVER=("sftp' "sshd" "rss")
SERVER=('sftp' 'sshd') # rss are not supported for now
PROTOCOL='tcp'
DOMAIN='channingtong.cn'
SSH_COMMAND_ARRAY=()

# ask user to provide identity to generate ssh-key
#echo "Please provide your email to generate ssh-key"
#read EMAIL
## email validation check
#if [[ ! $EMAIL =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
#    echo "Invalid email address"
#    # input again
#    read EMAIL
#fi

for server in ${SERVER[@]}
do
    SRC_COMMAND="_${server}._${PROTOCOL}.${DOMAIN}"
    #echo $SRC_COMMAND
    SRC_SOURCE=$(dig +short SRV $SRC_COMMAND)
    PORT=$(echo $SRC_SOURCE | awk -F ' ' '{print $3}')
    SSH_COMMAND_ARRAY+=("ssh -o Port=${PORT} ${server}.${DOMAIN}\n")
    SSH_CONFIG_PATH="$HOME/.ssh/"
    SSHKEY_NAME="channingtong_${server}"
    echo $SSHKEY_NAME
    SSHKEY_PATH="${SSH_CONFIG_PATH}${SSHKEY_NAME}"
    # check ssh-key, if not exist, add it
    if [-e "${SSHKEY_PATH}"]; then
        echo "ssh-key exist"
    else
        ssh-keygen -t rsa -b 4096 -f ${SSHKEY_PATH} -N ""
    fi
    echo $"added ${server} server"
done
echo -e ${SSH_COMMAND_ARRAY[@]}