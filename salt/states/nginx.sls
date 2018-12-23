---

nginx:
  pkg.installed

/usr/local/etc/nginx:
  file.directory:
    - makedirs: True

nginx:
  service.running:
    - enable: True
    - require:
      - pkg: nginx
      - file: /usr/local/etc/nginx
