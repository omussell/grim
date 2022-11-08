## Get firecracker
release_url="https://github.com/firecracker-microvm/firecracker/releases"
latest=$(basename $(curl -fsSLI -o /dev/null -w  %{url_effective} ${release_url}/latest))
curl -L ${release_url}/download/${latest}/firecracker-${latest}-x86_64.tgz | tar -xz





```
dest_kernel="hello-vmlinux.bin"
dest_rootfs="hello-rootfs.ext4"
image_bucket_url="https://s3.amazonaws.com/spec.ccfc.min/img/quickstart_guide/x86_64"


kernel="${image_bucket_url}/kernels/vmlinux.bin"
rootfs="${image_bucket_url}/rootfs/bionic.rootfs.ext4"

curl -fsSL -o $dest_kernel $kernel
curl -fsSL -o $dest_rootfs $rootfs
```

But replace kernel with 5.10:
https://s3.amazonaws.com/spec.ccfc.min/ci-artifacts/kernels/x86_64/vmlinux-5.10.bin

and follow steps here to get an alpine rootfs
https://github.com/firecracker-microvm/firecracker/blob/main/docs/rootfs-and-kernel-setup.md

or could maybe grab the mini root filesystem from here: https://alpinelinux.org/downloads/
https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-minirootfs-3.16.2-x86_64.tar.gz
Tarball contains whole root filesystem. Maybe could follow those instructions: create block device via dd (or zfs?), make it ext4, mount it to a temp directory, then extract the tarball onto it?

Would need reliable update/upgrade method, will need to do this for every alpine update
