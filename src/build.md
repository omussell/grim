## Get firecracker
release_url="https://github.com/firecracker-microvm/firecracker/releases"
latest=$(basename $(curl -fsSLI -o /dev/null -w  %{url_effective} ${release_url}/latest))
curl -L ${release_url}/download/${latest}/firecracker-${latest}-x86_64.tgz | tar -xz





```
dest_kernel="vmlinux.bin"
kernel="https://s3.amazonaws.com/spec.ccfc.min/ci-artifacts/kernels/x86_64/vmlinux-5.10.bin"
curl -fsSL -o $dest_kernel $kernel
```

But replace kernel with 5.10:
https://s3.amazonaws.com/spec.ccfc.min/ci-artifacts/kernels/x86_64/vmlinux-5.10.bin
need to better understand/document how this kernel file is created. Their CI builds it so it must be in the CI config.

and follow steps here to get an alpine rootfs
https://github.com/firecracker-microvm/firecracker/blob/main/docs/rootfs-and-kernel-setup.md

or could maybe grab the mini root filesystem from here: https://alpinelinux.org/downloads/
https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-minirootfs-3.16.2-x86_64.tar.gz
Tarball contains whole root filesystem. Maybe could follow those instructions: create block device via dd (or zfs?), make it ext4, mount it to a temp directory, then extract the tarball onto it?

NOTE: Would need reliable update/upgrade method, will need to do this for every alpine update


The above worked, downloaded the 5.10 kernel, and made a new ext4 device. After mounting to tmp folder, extracted the miniroot tarball into it. But it wouldnt start due to openrc not being installed. So since I'm on ubuntu, I downloaded the statically linked `apk` binary, then ran the `apk add openrc util-linux` command. Dont know what util-linux is for.

```
https://wiki.alpinelinux.org/wiki/Alpine_Linux_in_a_chroot
curl -LO https://dl-cdn.alpinelinux.org/alpine/latest-stable/main/x86_64/apk-tools-static-2.12.9-r3.apk
tar -xzf apk-tools-static-*.apk
/tmp/my-rootfs# ~/sbin/apk.static -U --allow-untrusted -p . --initdb add openrc util-linux
```

Then after running the following firecracker commands, the VM starts, albeit with no TTY/console or network setup.

firecracker --api-sock /tmp/firecracker.socket

NOTE: This is setting the config by curling the API socket, you can alternatively pass a config.json file to the firecracker binary.

set the guest kernel

kernel_path=$(pwd)"/vmlinux.bin"

curl --unix-socket /tmp/firecracker.socket -i \
  -X PUT 'http://localhost/boot-source'   \
  -H 'Accept: application/json'           \
  -H 'Content-Type: application/json'     \
  -d "{
        \"kernel_image_path\": \"${kernel_path}\",
        \"boot_args\": \"console=ttyS0 reboot=k panic=1 pci=off\"
   }"

set the rootfs

rootfs_path=$(pwd)"/rootfs.ext4"
curl --unix-socket /tmp/firecracker.socket -i \
  -X PUT 'http://localhost/drives/rootfs' \
  -H 'Accept: application/json'           \
  -H 'Content-Type: application/json'     \
  -d "{
        \"drive_id\": \"rootfs\",
        \"path_on_host\": \"${rootfs_path}\",
        \"is_root_device\": true,
        \"is_read_only\": false
   }"

start the vm

curl --unix-socket /tmp/firecracker.socket -i \
  -X PUT 'http://localhost/actions'       \
  -H  'Accept: application/json'          \
  -H  'Content-Type: application/json'    \
  -d '{
      "action_type": "InstanceStart"
   }'

get status

curl --unix-socket /tmp/firecracker.socket -i \
  -X GET 'http://localhost/'       \
  -H  'Accept: application/json'          \
  -H  'Content-Type: application/json'    

get config

curl --unix-socket /tmp/firecracker.socket -i \
  -X GET 'http://localhost/vm/config' \
  -H  'Accept: application/json' \
  -H  'Content-Type: application/json'


Networking setup
https://github.com/firecracker-microvm/firecracker/blob/main/docs/network-setup.md

On host, need to create tap interface for each microvm then set up NAT using iptables. Could/should we use nftables?
https://github.com/google/nftables


Do we need to use the MMDS service? Can be used for passing basic metadata to the uvm.
https://github.com/firecracker-microvm/firecracker/blob/main/docs/mmds/mmds-user-guide.md







The created /srv/jailer/firecracker/$UUID/root directory is the chroot dir, not roots home directory. So the kernel and rootfs files need to be copied into there, and referred to like current directory "./vmlinux.bin" etc.

curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i \
  -X PUT 'http://localhost/boot-source'   \
  -H 'Accept: application/json'           \
  -H 'Content-Type: application/json'     \
  -d "{
        \"kernel_image_path\": \"./vmlinux.bin\",
        \"boot_args\": \"console=ttyS0 reboot=k panic=1 pci=off\"
   }"

set the rootfs

curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i \
  -X PUT 'http://localhost/drives/rootfs' \
  -H 'Accept: application/json'           \
  -H 'Content-Type: application/json'     \
  -d "{
        \"drive_id\": \"rootfs\",
        \"path_on_host\": \"./rootfs.ext4\",
        \"is_root_device\": true,
        \"is_read_only\": false
   }"

NOT WORKING YET
Add tap interface into uvm
curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i \
  -X PUT 'http://localhost/network-interfaces/eth0' \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
      "iface_id": "eth0",
      "host_dev_name": "tap0"
    }'

start the vm

curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i \
  -X PUT 'http://localhost/actions'       \
  -H  'Accept: application/json'          \
  -H  'Content-Type: application/json'    \
  -d '{
      "action_type": "InstanceStart"
   }'

stop the vm

curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i \
  -X PUT 'http://localhost/actions'       \
  -H  'Accept: application/json'          \
  -H  'Content-Type: application/json'    \
  -d '{
      "action_type": "SendCtrlAltDel"
   }'

Sending ctrl+alt+del will trigger restart/reboot, which kills the VM. Also kills the jailer process. But doesnt clean up after itself.

get status

curl --unix-socket /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket -i \
  -X GET 'http://localhost/'       \
  -H  'Accept: application/json'          \
  -H  'Content-Type: application/json'    

get config

curl --unix-socket /tmp/firecracker.socket -i \
  -X GET 'http://localhost/vm/config' \
  -H  'Accept: application/json' \
  -H  'Content-Type: application/json'


Networking setup
https://github.com/firecracker-microvm/firecracker/blob/main/docs/network-setup.md

On host, need to create tap interface for each microvm then set up NAT using iptables. Could/should we use nftables?
https://github.com/google/nftables
