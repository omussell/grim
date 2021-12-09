- Do proof of concept first by manually setting all this stuff and running through it all.
- Do multipass on Gen10









- compute nodes and storage nodes
- just regular servers. compute has lots of cpu+ram. storage has lots of drive storage.
- storage nodes just pool the drives together into zpools. leave it up to the user to decide how.


- metrics and monitoring - grafana+loki+cortex+tempo


# Problems with existing solutions

- cloud is great, but way overcomplicated and very expensive
- some infra components just dont make sense being put in the cloud
- have to retrain all your staff all over again. everything they've learned over the past 2 decades is now irrelevant. New hires are expensive and hard to find.
- openstack is the closest on premises competitor. Its also very complicated and hard to set up.
- Some cloud services like heroku offer to take away the complexity, but again at higher cost.
- Small cloud services like deta which serve a small niche are a good idea, but again, high cost.
- kubernetes is great, but complicated, hard to do right, and YAML
- dont want to care about networking, dumb COTS switches. IPv4

Using Kubernetes on GCP+Azure at work, I keep running into common problems. 

Its difficult for app teams to run their apps locally. Its a lot of effort to get apps converted into Docker and getting them running locally, in CI for testing, and then deployed for production use. We need 3 different types of configuration which are very different from each other. Its hard to take legacy apps and get them running on K8s and Docker. They keep getting shoehorned onto k8s. Its difficult for us to scale the apps because its hard to give them enough resources without requiring massive nodes.

Likewise Kubernetes only works for stateless apps. If you need any other software like redis, postgres, mysql etc you need to pay for a managed service because they wont work well on Kubernetes and its obviously so very difficult to run yourself.

Kubernetes itself is also so hard to manage that you are strongly recommended to use a managed/hosted version. You would be considered foolish to run a cluster yourself. So why are we using this crappy software again?

We are wholly dependent on these cloud services to manage this stuff, under the pretence that it is a lot of effort for us to manage. However, I reckon thats bullshit. Spinning up VMs on the cloud is very easy and they arent that hard to manage. Patching and updates etc, HA is a solved problem. They just need puppet modules writing, then everyone in the world can work the same way.

## Config management

We keep running into problems with creating Terraform code, because we're creating so many resources for all sorts of different things. The Terraform HCL is a shit language which is just getting more and more stuff bolted on. There are providers being created to manage things in Terraform which arent suitable for it.

We should not be creating complicated code, because it leads to a complicated infrastructure. Terraform can be kept simple, create X VMs with these different names.

## Scale

Everyone seems to be obsessed with scale. Our apps are going to be used by thousands of people, and at the minute with our K8s apps we are struggling to have enough pods/nodes to handle a few dozen users. We have stuff running on FreeBSD on VMs which is handling thousands of users with way fewer resources. If we were using Linux instead we would probably get even better performance.

How do you scale a Kubernetes cluster?

Pods can be given more CPU/RAM via the requests and limits. Very often, these are set to very low values. You are forced to do this since K8s uses the pod limits to determine if new nodes are required, and you want to be able to fit more than one app on a single node.

The cloud provider manages the creation/deletion of new nodes. This is done when a new pod is scheduled and cant be allocated due to lack of space. So now you are in a position that you need to scale your app as per the Horizontal Pod Autoscaler, but cant, because you have to wait for a new node. This takes a while, in the meantime your users have to wait.

The HPA only works on two metrics out of the box: CPU used, and packets per second. Most applications will lock up before ever hitting a certain CPU threshold. Likewise, who came up with packets per second as a metric? How many packets are in a HTTP request? Depends on the request. Why not requests per second? 

If you cant use either of those metrics, you are forced to have a custom metric.


 

# Possible solutions

## Traditional route

- Puppet for config management, app config and secrets
- Puppet master helper services written in Go
- Fabric for imperative management
- Clear demarcation between what goes into Puppet, and what goes into Fabric.
- BUBO (BU), build service for building app artifacts/packages, distributing them with SSH
- BUBO2 (BO)/ automation engine, automation for doing regular tasks, but guided by humans. Like if new patches are released, BUBO2 has a page to select groups of VMs and start rolling patching servers. Everything it does should be done via Fabric, so that either BUBO2 can do it, or a human can do it too.
- Monitoring with Prometheus
- Load balancer with NGINX. Configured with Puppet. Just a bunch of VMs, running NGINX, which proxy requests to the backends.
- VMs created in cloud provider using Terraform. VMs should be regular standalone VMs, not in a Managed Instance Group, ScaleSet or other magic autoscaling group.
- VMs arranged into different groups. So if I want to patch X prod app servers, its just changing some flags. If I want to instead patch everything in X prod, its the same with just flags. Fabric should respect certain groupings. Like if patching X prod, it should split varnish group, app group, db group etc so HA is maintained.
- GOSS for infra testing, rather than serverspec
- Puppet profiles for standalone PGSQL, Redis, RabbitMQ etc.
- Puppet profiles for PGSQL with replication, Redis with Sentinel and HAProxy, RabbitMQ cluster, 
- Fabric scripts for upgrading PGSQL, Redis, RabbitMQ without downtime.
- PGSQL backup scripts
- Puppet profiles for Apache + PHP + MySQL
- Can have container hosts which run firecracker VMs, and normal hosts where the app uses the whole VM and configured with Puppet
- Stuff that is mainly machine driven, like autosigning and API stuff, should be in Go. If humans are touching it a lot, like Fabric, then it should be in Python since its easier to write.
- Metadata server which runs NTP and DNS. Internal services can query this metadata server to get DNS info about other internal services
- Maybe have Hiera for Apps, DBs, Containers, Local
- Firecracker for containers. Dont need nomad or k8s or other orchestrator. Just let the human use Puppet+Fabric to decide. Set X VMs as the container hosts for X app. Run Fabric, it only deploys X app on X VMs. Easy.
- Jails on FreeBSD fit the problem perfectly, but plagued by compatibility problems. Need Linux equivalent.


This infra:

- Works across many different OSes
- Works for all software
- Mature, battle tested for a decade
- Has an easy to understand DSL
- Can include secrets

 
Uncertain:

- Dont store stuff in puppet-control which shouldnt be, like which containers are running. That should be handled by Fabric exclusively.
- Firecracker instead of LXD or chroot. Can firecracker only use alpine base? LXC without LXD? LXD needs snap, but can I just compile it myself? Otherwise, what about plain old systemd-nspawn and do it like jails?
- Could include ability to run Docker containers on app hosts
- Fabric could use PuppetDB for inventory
- BUBO workers could be long running firecracker VMs configured with puppet and controlled via fabric
- Dont run Puppet agent as a service. Only run it when the human wants to. The VMs should never change unless a human invokes changes to happen.


Deploy process:
    - bubo does build
    - fabric connect to X container hosts, create new firecracker VM
    - fabric connect into firecracker VMs, run puppet which downloads bubo built files, starts app under s6/supervisor/systemd
    - fabric connects to X container hosts, reconfigure NGINX to point at new VMs
    - update internal DNS on metdata server

## Firecracker route

- Alpine host, firecracker running Alpine VMs. Simpler than fly.io, similar to Fargate. Give it a config file / task definition, it figures out how and where to deploy it. Metrics and monitoring are baked in.

- Or ubuntu host and VMs, depends how it goes.

- The firecracker VMs can run one or more docker containers. Your task definition just says which docker images to use.

- Want to use Postgres, Redis or Rabbit, then just use those images.

- Need to look into secrets management

- Ansible for provisioning the hosts

- Managed by Go app, web interface for humans. Keeps track of which VM hosts are available. It handles deployments.

- Dont be like k8s with magical autoscaling. Have it show how much CPU/RAM/Disk is available. Group hosts together for hosts with similar properties. Small number with low CPU/RAM, small number with high CPU/RAM, large number with low CPU etc. Then you can let the humans decide which Group they want the VMs to be running on. It figures out if there is capacity and distributes across nodes, and if over provisioned, warns but lets you do it if you want. 

- Storage for VMs, dont use ZFS because it has its own problems. Look at Ext4 with LVM per VM.

- Networking and routing, Go app runs metadata service too, so VMs can query it via DNS and find other VMs. Firewall rules etc. needs figuring out.

I've got the basic firecracker setup figured out. Need to figure out how to get the jailer working. 

Once jailer is working, you should have all the commands required to start/stop microVMs. Then need to figure out:

- Running docker containers inside the VMs
- Networking
- Storage

# End result

- Sysadmins can spend less time hand holding developers and more time managing the infrastructure. The idea that with K8s you dont need Ops is ridiculous. Now you need Ops with even more experience who are even more expensive.
- Local dev can work in the same way that you thought about with Skaffold. A VM with a ingress+certs set up already, then if you need different services like databases etc, you just cd into each folder which then sets up each service.

