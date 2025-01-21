VISITOR_ACCOUNT='visitor'
PUBKEY_PATH=$1
FRPC_DOMAIN=$2
PORT=$3
echo "add pubkey to $FRPC_DOMAIN:$PORT"
echo $OS
if ("$OS" == "Windows (PowerShell)"); then
    echo "input the password "visitor" manully: (for expect is not supported in Windows)"
    ssh-copy-id -i $PUBKEY_PATH -p $PORT $VISITOR_ACCOUNT@$FRPC_DOMAIN
else
    expect << EOF
    spawn ssh-copy-id -i $PUBKEY_PATH -p $PORT $VISITOR_ACCOUNT@$FRPC_DOMAIN
    expect "${VISITOR_ACCOUNT}@${FRPC_DOMAIN}'s password: "
    send "visitor\r"
    expect eof
    EOF
fi
