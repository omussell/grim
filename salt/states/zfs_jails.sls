{{ salt['pillar.get']('zfs_jails_mount') }}:
  file.directory

{{ salt['pillar.get']('zfs_jails_template_dataset') }}:
  zfs.filesystem_present:
    - properties:
      - mountpoint: {{ salt['pillar.get']('zfs_jails_mount') }}/{{ salt['pillar.get']('zfs_jails_template_name') }}

{{ salt['pillar.get']('zfs_jails_mount') }}/{{ salt['pillar.get']('zfs_jails_template_name') }}:
  archive.extracted:
    - source: {{ salt['pillar.get']('base_ftp_file') }}
    - skip_verify: True

{{ salt['pillar.get']('zfs_jails_template_dataset') }}@{{ salt['pillar.get']('zfs_jails_snapshot_name') }}:
  zfs.snapshot_present

{% for jail in salt['pillar.get']('jails_present') %}
tank/{{ jail }}:
  zfs.filesystem_present:
    - cloned_from: {{ salt['pillar.get']('zfs_jails_template_dataset') }}@{{ salt['pillar.get']('zfs_jails_snapshot_name') }}
    - properties:
      - mountpoint: {{ salt['pillar.get']('zfs_jails_mount') }}/{{ jail }}

start_jails:
  module.run:
    - name: jail.start
    - jail: {{ jail }}

{% endfor %}
