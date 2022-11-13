https://github.com/firecracker-microvm/firecracker/blob/main/docs/network-setup.md

- On the host, each uVM needs a tap device, an IP address not in host subnet and iptables rules for NAT 
- When starting the uVM, need to pass is the tap device name
- Inside the guest, need to bring up the network interface and also add nameserver to resolv.conf
