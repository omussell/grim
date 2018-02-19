{% for group, args in pillar['groups'].items() %}
{{ group }}:
  group.present:
    - name: {{ group }}
{% if 'gid' in args %}
    - gid: {{ args['gid'] }}
{% endif %}
{% endfor %}
