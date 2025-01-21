#!/bin/bash
# install dependency
bash ./install.sh
#SERVER=("sftp' "sshd" "rss")
SERVER=('sftp' 'sshd') # rss are not supported for now
PROTOCOL='tcp'
DOMAIN='channingtong.cn'
FRPC_DOMAIN='9.nat0.cn'
# ask user to provide identity to generate ssh-key
echo "Please provide your username to generate ssh-key"
read USERNAME
# check whether name string contains invalid character
if [[ $USERNAME =~ [^a-zA-Z0-9] ]]; then
    echo "Invalid username, no special character please."
    exit 1
fi
# create alias command file under /usr/local/bin
EXECUTE_FILE="./connectTong"
touch $EXECUTE_FILE
echo $"#!/bin/bash" > $EXECUTE_FILE
echo "SERVER_TYPE=\$1" >> $EXECUTE_FILE
# generate ssh-key for each server
for server in ${SERVER[@]}
do
    SRC_COMMAND="_${server}._${PROTOCOL}.${DOMAIN}"
    SRC_SOURCE=$(dig +short SRV $SRC_COMMAND)
    PORT=$(echo $SRC_SOURCE | awk -F ' ' '{print $3}')
    # echo $SSH_COMMAND
    SSH_CONFIG_PATH="$HOME/.ssh/"
    SSHKEY_NAME="${USERNAME}2channingtong_${server}"
    echo "key name is ${SSHKEY_NAME}"
    SSHKEY_PATH="${SSH_CONFIG_PATH}${SSHKEY_NAME}"
    # check ssh-key, if not exist, add it
    if [ -e "${SSHKEY_PATH}" ]; then
        echo "ssh-key exist"
    else
        ssh-keygen -t rsa -b 4096 -f ${SSHKEY_PATH} -N ""
    fi
    # use visitor account to add public key to server
    bash ./add_pubkey.sh ${SSHKEY_PATH}.pub $FRPC_DOMAIN $PORT
    SSH_COMMAND="ssh -i ${SSHKEY_PATH} -p ${PORT} visitor@${FRPC_DOMAIN}"
    # add command to /usr/local/bin/connectTong.sh
    echo "if [ \$SERVER_TYPE == '${server}' ]; then" >> $EXECUTE_FILE
    echo "    ${SSH_COMMAND}" >> $EXECUTE_FILE
    echo "fi" >> $EXECUTE_FILE 
    echo $"added ${server} server"
    # add rsync command when generate sftp server
    if [ $server == 'sftp' ]; then
        RSYNC_COMMAND="rsync -avz -e 'ssh -i ${SSHKEY_PATH} -p ${PORT}' "
        echo "if [ \$SERVER_TYPE == 'pull' ]; then" >> $EXECUTE_FILE
        echo "  ORIENT_PATH=\$2" >> $EXECUTE_FILE
        echo "  LOCAL_PATH=\$3" >> $EXECUTE_FILE
        echo "  ${RSYNC_COMMAND} visitor@${FRPC_DOMAIN}:/mnt/repo/\$ORIENT_PATH \$LOCAL_PATH" >> $EXECUTE_FILE
        echo "fi" >> $EXECUTE_FILE
        echo "if [ \$SERVER_TYPE == 'push' ]; then" >> $EXECUTE_FILE
        echo "  ORIENT_PATH=\$2" >> $EXECUTE_FILE
        echo "  LOCAL_PATH=\$3" >> $EXECUTE_FILE
        echo "  ${RSYNC_COMMAND} \$LOCAL_PATH visitor@${FRPC_DOMAIN}:/mnt/repo/\$ORIENT_PATH" >> $EXECUTE_FILE
        echo $"added rsync command"
    fi
done
if ("$OS" == "Windows (PowerShell)"); then
    echo "input the password "visitor" manully: (for expect is not supported in Windows)"
    ssh-copy-id -i $PUBKEY_PATH -p $PORT $VISITOR_ACCOUNT@$FRPC_DOMAIN
else
if [["$OS" == "Windows*"]];
    echo "Use shell manually under this folder "
    EXECUTE_FILE+=".sh"
else
    sudo mv $EXECUTE_FILE /usr/local/bin/
    sudo chmod +x /usr/local/bin/connectTong
fi