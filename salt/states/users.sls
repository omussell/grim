---

git_remote:
  user.present:
    - home: "/usr/local/git"
    - shell: "/usr/local/bin/git-shell"

#{% for group, args in pillar['groups'].items() %}
#group-{{ group }}:
#  group.present:
#    - name: {{ group }}
#{% if 'gid' in args %}
#    - gid: {{ args['gid'] }}
#{% endif %}
#{% endfor %}

{% for user, args in pillar['users'].items() %}
user-{{ user }}:
  user.present:
    - home: {{ args['home'] }}
    - shell: {{ args['shell'] }}
{% if 'password' in args %}
    - password: {{ args['password'] }}
{% if 'enforce_password' in args %}
    - enforce_password: {{ args['enforce_password'] }}
{% endif %}
{% endif %}
{% if 'groups' in args %}
    - groups: {{ args['groups'] }}
{% endif %}
    - require:
      - group: {{ user }}

{% if 'key.pub' in args and args['key.pub'] == True %}
{{ user }}_key.pub:
  ssh_auth:
    - present
    - user: {{ user }}
    - source: salt://users/{{ user }}/keys/key.pub
{% endif %}

group-{{ user }}:
  group.present:
    - name: {{ user }}

{% endfor %}
