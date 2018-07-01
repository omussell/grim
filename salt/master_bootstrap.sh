#! /bin/sh

BOOTSTRAP_URL='https://bootstrap.saltstack.com'
MASTER_CFG_URL='https://raw.githubusercontent.com/omussell/grim/master/salt/master'

pkg install -y ca_root_nss
fetch $BOOTSTRAP_URL -o salt_bootstrap.sh
chmod +x salt_bootstrap.sh
sysrc salt_master_enable=YES
sysrc salt_minion_enable=YES
./salt_bootstrap.sh
./salt_bootstrap.sh -M
pkg install -y git py36-gitpython
fetch $MASTER_CFG_URL -o /usr/local/etc/salt/master
service salt_master restart

