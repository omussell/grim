py36-salt:
  pkg.installed

git:
  pkg.installed

py36-gitpython:
  pkg.installed

/usr/local/etc/salt/master:
  file.managed:
    - source:
      - https://raw.githubusercontent.com/omussell/grim/master/salt/master

salt_master:
  sysrc.managed:
    - value: "YES"

salt_master:
  service.running:
    - enable: True
    - require:
      - file: /usr/local/etc/salt/master
    - watch:
      - file: /usr/local/etc/salt/master
