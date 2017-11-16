/usr/local/jails:
  file.directory

tank/template:
  zfs.filesystem_present:
    - properties:
      - mountpoint: /usr/local/jails/template_11_1

/usr/local/jails/template_11_1:
  archive.extracted:
    - source: ftp://ftp.freebsd.org/pub/FreeBSD/releases/amd64/amd64/11.1-RELEASE/base.txz
  - skip_verify: True

tank/template@1:
  zfs.snapshot_present

tank/testjail1:
  zfs.filesystem_present:
    - cloned_from: tank/template@1
    - properties:
      - mountpoint: /usr/local/jails/testjail1

start_jails:
  module.run:
    - name: jail.start
    - jail: testjail1
