---

knot2:
  pkg.installed:
    - version: 2.5.3

knot_enable:
  sysrc.managed:
    - name: knot_enable
    - value: YES

knot_config:
  sysrc.managed:
    - name: knot_config
    value: /usr/local/etc/knot/knot.conf

knot:
  service.running
