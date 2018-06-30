#! /bin/sh

pkg install -y ca_root_nss
fetch https://bootstrap.saltstack.com -o salt_bootstrap.sh
chmod +x salt_bootstrap.sh
sysrc salt_master_enable=YES
sysrc salt_minion_enable=YES
./salt_bootstrap.sh
./salt_bootstrap.sh -M
pkg install -y git py36-gitpython
fetch https://raw.githubusercontent.com/omussell/grim/master/salt/master -o /usr/local/etc/salt/master
service salt_master restart


#py36-salt:
#  pkg.installed
#
#git:
#  pkg.installed
#
#py36-gitpython:
#  pkg.installed
#
#/usr/local/etc/salt/master:
#  file.managed:
#    - source:
#      - https://raw.githubusercontent.com/omussell/grim/master/salt/master
#
#salt_master:
#  sysrc.managed:
#    - value: "YES"
#
#salt_master:
#  service.running:
#    - enable: True
#    - require:
#      - file: /usr/local/etc/salt/master
#    - watch:
#      - file: /usr/local/etc/salt/master