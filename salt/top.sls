#base:
{{ saltenv }}:
  '*':
#    - states/examples
#    - states/git
#    - states/ssh
    - states/zfs_jails
#    - states/users
##    - states/groups
#    - states/openntpd
#    - states/build

#develop:
#  '*':
#    - states/daemontools
