#base:
{{ saltenv }}:
  '*':
    - users
    - groups
    - zfs_jails/init
base:
  '*':
    - users
    - groups
    - zfs_jails
