#!/bin/bash -e

if [ -d secret ]; then
  echo 'Already created'
  exit
fi

pass=$1

mkdir secret
cd secret

keytool -genkey -v -keystore crystap.jks -keyalg RSA -keysize 2048 -validity 1000000 -alias crystap -storepass $pass -keypass $pass -dname "CN=luan.xyz,OU=,O=,L=,S=,C="

cat << EOF > key.properties
storePassword=$pass
keyPassword=$pass
keyAlias=crystap
storeFile=../keys/crystap.jks
EOF

