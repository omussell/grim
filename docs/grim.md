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
