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

Central to all these nodes is the control node, which runs the grim app. it provides a web interface for managing the infra.
When ad hoc commands are needed, the control node just ssh's to the node via fabric.
Likewise if alpine updates are needed, just ssh and apply them.
Can be one control node per env, or one for all envs.


storage nodes just pool the drives together into zpools. leave it up to the user to decide how.
storage nodes are running something like seaweedfs to provide object storage and networked file storage.



kaniko for container building
tekton for CI/CD

tanka for managing k8s resources
can link to helm charts so dont need to reinvent wheel

running k3s on each node
storage nodes run k3s with seaweedsfs


metrics and monitoring
grafana+loki+cortex+tempo

vaultwarden for password management
gitea for git repos
