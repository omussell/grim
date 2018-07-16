---

git:
  pkg.installed

/var/git:
  file.directory:
    - makedirs: True

for each git user, create the user, assign git-shell as login shell and make sure they cannot log in interactively

{% for user, args in pillar['users'].items() %}
user-{{ user }}:
  user.present:
    - home: /home
    - shell: {{ args['shell'] }}
    - shell: "/usr/local/bin/git-shell"
{% if 'groups' in args %}
    - groups: {{ args['groups'] }}
{% endif %}
    - require:
      - group: {{ user }}

{{ user }}_key.pub:
  ssh_auth:
    - present
    - user: {{ user }}
    - source: salt://users/{{ user }}/keys/key.pub

group-{{ user }}:
  group.present:
    - name: {{ user }}

no-login-{{ user }}:
file.managed:
  - name: /$USER_HOME/git-shell-commands/no-interactive-login
  - source: salt://templates/git-shell
  - recurse: true # make sure the directory exists before creating the file

{% endfor %}
