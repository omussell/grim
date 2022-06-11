# Main Idea

- Machine - Either bare metal or VM or VM on cloud provider
- Machine can be running Ubuntu or Alpine
- Machine needs KVM

- The Machine runs the grim-agent binary, which manages generating Firecracker microVMs and isolating them with the jailer
- Each Firecracker microVM runs the grim-uvm, which manages pulling the container images and starting the processes
- grim-uvm does this via containerd, runc and cni

- More than one Machine's are arranged into logical groups. No clustering, and they arent aware of each other, they are completely independent from one another.
- Some other machine somewhere, is running the grim binary. This is the CLI and web UI for talking to the grim-agent on the Machine's. It allows humans to collate Machine's into logical groups.
- The grim binary is where the central management happens. It decides which containers run on which Machines.

- Humans can notify the web UI of new containers / deployments by providing it with a Task Definition file. This is similar to the one used on AWS Fargate. It denotes how much CPU/RAM to allocate, which group to assign to, and which images to use.

# Alternative

- Use LXD for containerisation instead of full VMs. Less flexible because need Ubuntu+Snap. Means can run on cloud though because sometimes you cant use nested virtualisation.
- Use puppet for controlling all config and app deployment config. This means its just one DSL to learn rather than K8s yaml, CI/CD yaml, Docker, bash etc.
- Create BUBO server for CI/CD
- Puppet shouldnt store what containers are running where, otherwise you need to have every app deployment be a change to the puppet repo which gets messy. Let LXD do that bit, and puppet figure it out. Maybe need fabric for glue.

# Other alternative

Closer to what Heroku, Deta and Fly.io are doing. Provide a CLI/API which you give a basic task definition with a dockerfile, and we run it. Apps, load balancers, storage, DBs. 

Maybe a combination of both approaches. We use puppet etc. to manage the actual infra, which is quite basic like storage is just ZFS with block volumes exposed over NFS. Then we just connect them up using a nice and simple CLI/API interface.

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

Wireguard for inter-host traffic where required for e.g. DB replication. Management layer done with SSH. SSHFP records pulled from the host via puppet and updated on some other system so that DNS can be updated. Then when management box connects to hosts it can use DNS for host validation.

Install fluent bit and maybe other monitoring plugins within the microVM.
