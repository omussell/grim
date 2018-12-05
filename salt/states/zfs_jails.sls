{{ pillar['zfs_jails_mount'] }}:
  file.directory

{{ pillar['zfs_jails_template_dataset'] }}:
  zfs.filesystem_present:
    - properties:
      - mountpoint: {{ pillar['zfs_jails_mount'] }}/{{ pillar['zfs_jails_template_name'] }}

{{ pillar['zfs_jails_mount'] }}/{{ pillar['zfs_jails_template_name'] }}:
  archive.extracted:
    - source: {{ pillar['base_ftp_file']
  - skip_verify: True

{{ pillar['zfs_jails_template_dataset'] }}@{{ pillar['zfs_jails_snapshot_name'] }}:
  zfs.snapshot_present

{% for jail, args in pillar['jails_present'].items() %}
tank/{{ jail }}:
  zfs.filesystem_present:
    - cloned_from: {{ pillar['zfs_jails_template_dataset'] }}@{{ pillar['zfs_jails_snapshot_name'] }}
    - properties:
      - mountpoint: {{ pillar['zfs_jails_mount'] }}/{{ jail }}

start_jails:
  module.run:
    - name: jail.start
    - jail: {{ jail }}

{% endfor %}
