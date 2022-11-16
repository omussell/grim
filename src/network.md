https://github.com/firecracker-microvm/firecracker/blob/main/docs/network-setup.md

- On the host, each uVM needs a tap device, an IP address not in host subnet and iptables rules for NAT 
- When starting the uVM, need to pass is the tap device name
- Inside the guest, need to bring up the network interface and also add nameserver to resolv.conf


sudo ip tuntap add tap0 mode tap

#sudo ip addr add 172.16.0.1/24 dev tap0
sudo ip addr add 10.0.0.1/24 dev tap0
sudo ip link set tap0 up
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i tap0 -o eth0 -j ACCEPT


curl --unix-socket /tmp/firecracker.socket -i \
  -X PUT 'http://localhost/network-interfaces/eth0' \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
      "iface_id": "eth0",
      "guest_mac": "AA:FC:00:00:00:01",
      "host_dev_name": "tap0"
    }'
