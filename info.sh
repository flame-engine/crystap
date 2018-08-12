#!/bin/bash -e

sha1() {
  pass=`cat secret/key.properties | grep keyPassword | rex '^keyPassword=(.+)$' '$1'`
  keytool -list -v -keystore secret/crystap.jks -alias crystap -storepass $pass -keypass $pass 2> /dev/null | grep "SHA1:" | rex '\s*SHA1: (.*)' '$1'
}

pkg() {
  cat vanilla_android/app/src/main/AndroidManifest.xml | grep package | rex '.*package="([^"]+)".*' '$1'
}

echo "SHA1: `sha1`"
echo "Package name: `pkg`"
