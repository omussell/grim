#base:
{{ saltenv }}:
  '*':
    - users
    - groups
