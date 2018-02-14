#base:
{{ saltenv }}:
  '*':
    - states/examples
    - states/git
    - states/ssh
