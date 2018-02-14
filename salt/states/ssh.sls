---
/etc/ssh/ssh_config:
  file.exists

/etc/ssh/sshd_config:
  file.exists

ssh_config_template:
  file.managed:
    - name: /etc/ssh/ssh_config
    - source: salt://templates/ssh_config

sshd_config_template:
  file.managed:
    - name: /etc/ssh/sshd_config
    - source: salt://templates/sshd_config

sshd:
  service.running:
    - enable: True
    - require:
      - file: /etc/ssh/sshd_config
    - watch:
      - file: /etc/ssh/sshd_config

sshd_enable:
  sysrc.managed:
    - value: "YES"

sshd_rsa_enable:
  sysrc.managed:
    - value: "NO"

sshd_ecdsa_enable:
  sysrc.managed:
    - value: "NO"

sshd_ed25519_enable:
  sysrc.managed:
    - value: "YES"
