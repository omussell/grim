jails_present:
  testjail1:
    - ip: 192.168.1.25

zfs_jails_root: 'tank/jails'
zfs_jails_mount: '/usr/local/jails'
zfs_jails_template_dataset: '{{ pillar['zfs_jails_root'] }}/template'
zfs_jails_template_name: 'template_11_2'
base_ftp_file: 'nope'
zfs_jails_snapshot_name: '2018-12-05'
