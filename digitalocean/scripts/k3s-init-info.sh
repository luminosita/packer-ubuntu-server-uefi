#! /bin/bash

eval "$(jq -r '@sh "USERNAME=\(.username) IP_ADDRESS=\(.ip_address) PRIVATE_KEY_FILE=\(.private_key_file)"')"

token=$(/usr/bin/ssh $USERNAME@$IP_ADDRESS -o "IdentityFile $PRIVATE_KEY_FILE" -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile /dev/null' "sudo cat /var/lib/rancher/k3s/server/node-token")
certhash=$(/usr/bin/ssh $USERNAME@$IP_ADDRESS -o "IdentityFile $PRIVATE_KEY_FILE" -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile /dev/null' "sudo openssl x509 -pubkey -in /var/lib/rancher/k3s/server/tls/server-ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'")

jq -n --arg token "$token" --arg certhash "$certhash" '{"token":$token, "certhash":$certhash}'