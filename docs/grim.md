# Main Idea

- Replacement for LXD, Nomad, K8s etc. using Firecracker microVMs. Managed load balancing and storage layers built on regular VMs. 
- Intended for people using their own hardware, though if a cloud provider lets you run KVM via nested virtualization then it will work there too.

Alternative to regular cloud providers.

- Firecracker microVM orchestrator
- Load Balancer manager
- Storage manager
- Stateful services manager
- Language runtimes


- Machine - Either bare metal or VM or VM on cloud provider
- Machine can be running Ubuntu or Alpine
- Machine needs KVM

- The Machine runs the grim-agent binary, which manages generating Firecracker microVMs and isolating them with the jailer
- Each Firecracker microVM runs the grim-uvm, which manages pulling the container images and starting the processes
- grim-uvm does this via containerd, runc and cni

- More than one Machine's are arranged into logical groups. No clustering, and they arent aware of each other, they are completely independent from one another.
- Some other machine somewhere, is running the grim-server binary. This is the CLI and web UI for talking to the grim-agent on the Machine's. It allows humans to collate Machine's into logical groups and deploy new microVMs onto them.
- The grim-server binary is where the central management happens. It decides which containers run on which Machines.

- Humans can notify the API / web UI of new containers / deployments by providing it with a Task Definition file. This is similar to the one used on AWS Fargate. It denotes how much CPU/RAM to allocate, which group to assign to, and which images to use.

- Need to figure out the firecracker bootstrapping process
- Need to figure out the firecracker jailer without using firectl
- Need to figure out how to set up production hosts properly

Closer to what Heroku, Deta and Fly.io are doing. Provide a CLI/API which you give a basic task definition with a dockerfile, and we run it. Apps, load balancers, storage, DBs. 

Storage is just ZFS with block volumes exposed over NFS. Then we just connect them up using a nice and simple CLI/API interface.

Maybe running containers could just be with containerd. Would need to be able to pass env vars and mount storage devices.

Could use this: https://github.com/firecracker-microvm/firecracker-containerd on the host. Just need to coordinate getting the images etc. to this daemon

DBs would run in different ways:

- Inside microVMs
- 1 DB for 1 host

Then different types:

- Sqlite standalone
- Sqlite with Litestream
- Postgresql standalone
- Postgresql with HA

Need scripts for handling DB operations like upgrades, migrating to new host

Wireguard for inter-host traffic where required for e.g. DB replication. Management layer done with SSH. SSHFP records pulled from the host and updated on some other system so that DNS can be updated. Then when management box connects to hosts it can use DNS for host validation.

Install fluent bit and maybe other monitoring plugins within the microVM.

