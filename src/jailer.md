/usr/bin/jailer --id 551e7604-e35c-42b3-b825-416853441234 --cgroup cpuset.mems=0 --cgroup cpuset.cpus=$(cat /sys/devices/system/node/node0/cpulist) --exec-file /usr/bin/firecracker --uid 123 --gid 100 --netns /var/run/netns/my_netns --daemonize

/usr/bin/jailer --id 551e7604-e35c-42b3-b825-416853441234 --cgroup cpuset.mems=0 --cgroup cpuset.cpus=$(cat /sys/devices/system/node/node0/cpulist) --exec-file /usr/bin/firecracker --uid 1001 --gid 1111 --netns /var/run/netns/my_netns --daemonize

/usr/bin/jailer --id 551e7604 --exec-file /usr/bin/firecracker --daemonize

Defaults to /srv/jailer for storing chroots
Firecracker bin gets copied to /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/firecracker

The cgroup flags are for isolating processes, but can be left out and use default to not pin NUMA/CPU

netns is for network namespace, isolating network (route tables), need to assign network interface to netns. Can maybe assign the tap to this netns?

Assume we need to create a user and group for the UID and GID

"The user must create hard links for (or copy) any resources which will be provided to the VM via the API (disk images, kernel images, named pipes, etc) inside the jailed root folder. Also, permissions must be properly managed for these resources; for example the user which Firecracker runs as must have both read and write permissions to the backing file for a RW block device."

So create ZFS dataset for /srv/jailer, then have ZFS block device formatted with ext4 for the root filesystem

https://wiki.alpinelinux.org/wiki/Setting_up_a_new_user
     -h --home DIR           Home directory
     -g --gecos GECOS        GECOS field
     -s --shell SHELL        Login shell named SHELL by example /bin/bash
     -G --ingroup GRP        Group (by name)
     -D --disabled-password  Don't assign a password, so cannot login
     -H --no-create-home     Don't create home directory
     -u --uid UID            User id

addgroup -g GID UUID
adduser -h /srv/jailer/firecracker/UUID -g UUID -s /sbin/nologin -G ^GID -D -u UID
maybe use -H to not create the directory if jailer does it

UID is usually between 1000 and 60000

The firecracker API socket is at /srv/jailer/firecracker/551e7604-e35c-42b3-b825-416853441234/root/run/firecracker.socket

So once the jailer is running and created all that stuff you should be able to talk to the API as normal
