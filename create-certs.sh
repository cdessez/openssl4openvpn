#!/bin/sh
# Create all the certificates needed and the diffie-hellman parameters

# ./create-certs.sh my_common_name

if [ ! -z "$1" ]; then
  MY_CN=$1
else
  exit 666
fi

CA_CN="ca_$MY_CN"
SERVER_CN="server_$MY_CN"
CLIENT_CN="$MY_CN"
CNF_FILE="../openssl.cnf"

if [ ! -d keys ]; then
  mkdir keys
fi
if [ ! -d cert-reqs ]; then
  mkdir cert-reqs
fi
cd keys

## CA
# Create the CA's key and CRT
openssl req -new -x509 -batch \
      -subj "/CN=$CA_CN/name=$CA_CN" \
      -newkey rsa:1024 -keyout "$CA_CN.key" -out "$CA_CN.crt" -days 7300 -utf8 -nodes -config "$CNF_FILE"
chmod 600 "$CA_CN.key"
if [ ! -f index.txt ]; then 
  touch index.txt
fi
if [ ! -f index.txt.attr ]; then
  touch index.txt.attr
fi
echo "01" > serial


## SERVER
# Create the certificate request
openssl req -new -batch \
      -subj "/CN=$SERVER_CN/name=$SERVER_CN" \
      -newkey rsa:1024 -keyout "$SERVER_CN.key" -out "$SERVER_CN.csr" -days 1900 -utf8 -nodes -config "$CNF_FILE" \
      -extensions server
chmod 600 "$SERVER_CN.key"

# Sign my own certificate to use it for the server side
openssl ca -batch -keyfile "$CA_CN.key" -cert "$CA_CN.crt" -in "$SERVER_CN.csr" -out "$SERVER_CN.crt" -config "$CNF_FILE" \
    -extensions server


## CLIENT
# Create the certificate request
openssl req -new -batch \
      -subj "/CN=$CLIENT_CN/name=$CLIENT_CN" \
      -newkey rsa:1024 -keyout "$CLIENT_CN.key" -out "$CLIENT_CN.csr" -days 1900 -utf8 -nodes -config "$CNF_FILE" 
chmod 600 "$CLIENT_CN.key"


## DH
# Create diffie-hellman parameters
openssl dhparam -out "dh1024.pem" 1024

