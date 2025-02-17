#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

echo -e "${bold}[INSTALLING FRIDA]${normal}\n"

pip install frida-tools
pip install frida

VER=$(curl -s https://github.com/frida/frida | grep releases/tag | sed -nr 's/.*tag\/(.*)".*/\1/p')

echo -e "\n${bold}[DOWNLOADING FRIDA SERVER]${normal}\n"

wget https://github.com/frida/frida/releases/download/${VER}/frida-server-${VER}-android-x86.xz -O frida-server.xz -q --show-progress
xz -d frida-server.xz
adb.exe root
adb.exe remount
curl.exe -s --proxy http://127.0.0.1:8080 -o cacert.der http://burp/cert
adb.exe push frida-server /data/local/tmp/frida-server
adb.exe push cacert.der /data/local/tmp/cert-der.crt
adb.exe shell chmod +x /data/local/tmp/frida-server

openssl x509 -inform DER -in cacert.der -out cacert.pem
OPCOM=$(openssl x509 -inform PEM -subject_hash_old -in cacert.pem |head -1).0

cp cacert.der $OPCOM
adb.exe push $OPCOM /system/etc/security/cacerts/
adb.exe shell chmod 644 /system/etc/security/cacerts/$OPCOM


adb.exe shell reboot
rm $OPCOM cacert.der cacert.pem
