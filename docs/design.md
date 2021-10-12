cloud is great, but way overcomplicated and very expensive
some infras just dont make sense being put in the cloud
have to retrain all your staff all over again. everything they've learned over the past 2 decades is now irrelevant. New hires are expensive and hard to find.
openstack is the closest on premises competitor. Its also very complicated and hard to set up.
Some cloud services like heroku offer to take away the complexity, but again at higher cost.
Small cloud services like deta which serve a small niche are a good idea, but again, high cost.

kubernetes is great, but complicated, hard to do right, and YAML






dont want to care about networking, dumb COTS switches. IPv4

alpine linux for simplicity. can just use ubuntu/debian or any other well supported linux distro.


compute nodes and storage nodes
just regular servers. compute has lots of cpu+ram. storage has lots of drive storage.

on compute nodes, the desired applications can be run however you like. provide shell script which runs on the node, that can provision the app how you want.
the preferred method though is to run inside firecracker microvms
using jailer is optional
microvms are alpine too
maybe work like lambda, can give docker images, which we can just run with containerd/crio/runc/whatever. or alternatively the application can just be a tarball, and we provide microvms images which are "runtimes" with preinstalled software like python3.9 or go1.x.

no fancy clustering or k8s scaling magic. You give the size of the vm you want like 100mcpu or 1cpu, then we provision it.If the node has 192CPUs, you can divide it by X T shirt sizes. We should just let the admin and user decide about resource allocation, rather than the unseen magic that k8s does.
if the requested CPU exceeds the real amount, warn the user, and let them decide. might be that requested allocation exceeds, but actual utilisation is below. let the user decide, they can interpret the usage graphs
nodes are indepedent, but you can group them together. so app1 can be deployed to group1, which is made up of node1. app2 can be deployed to group2 with 2 VMs. if group2 has one node, then both are deployed on there, or if two nodes, then one on each. Not like k8s where you have to muck about with taints and tolerations or leave it up to the magic decision maker to hopefully spread them across nodes.

Central to all these nodes is the control node, which runs the grim app. it provides a web interface for managing the infra.
When ad hoc commands are needed, the control node just ssh's to the node via fabric.
Likewise if alpine updates are needed, just ssh and apply them.
Can be one control node per env, or one for all envs.


storage nodes just pool the drives together into zpools. leave it up to the user to decide how.
storage nodes are running something like seaweedfs to provide object storage and networked file storage.



buildbot for managing git triggers, building images or docker images, and then deploying


metrics and monitoring
grafana+loki+cortex+tempo

vaultwarden for password management
netbox for IPACreate an infrastructure with an emphasis on security, resiliency and ease of maintenance. 
