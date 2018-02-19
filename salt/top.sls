#base:
{{ saltenv }}:
  '*':
    - states/examples
    - states/git
    - states/ssh
    - states/users
#    - states/groups
