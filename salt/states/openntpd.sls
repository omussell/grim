---

openntpd:
  pkg.installed

ntpd_enable:
  sysrc.managed:
    - name: ntpd_enable
    - value: NO

openntpd_enable:
  sysrc.managed:
    - name: openntpd_enable
    - value: YES

openntpd_flags:
  sysrc.managed:
    - name: openntpd_flags
    - value: -sv

openntpd_service:
  service.running:
    - name: openntpd
    - enable: True
    - watch: 
      - sysrc: openntpd_enable
      - sysrc: openntpd_flags
      - pkg: openntpd
