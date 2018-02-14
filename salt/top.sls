#base:
{{ saltenv }}:
  '*':
    - states/examples
    - states/git
