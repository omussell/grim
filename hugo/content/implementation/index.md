---
#type: index
---

# Bootstrapping a Secure Infrastructure

*Oliver Mussell - 2016-2017*

Implementation
===

The architecture described in the design is only aimed at the infrastructure setup, not application servers. Each of the services provided can be accessed by other architectures based on different operating systems. So for example, Windows and Linux infrastructures would still be able to query the DNS service without any extra configuration.

StrictHostKeyChecking vs VerifyHostKeyDNS Problem:
---

### Problem Statement

Do the StrictHostKeyChecking and VerifyHostKeyDNS options in ssh_config work together?

- StrictHostKeyChecking - If set to yes, ssh will never automatically add host keys to the known_hosts file and refuses to connect to hosts whose host key has changed(This is the preferred option). The host keys of known hosts will be verified automatically in all cases.
- VerifyHostKeyDNS - Specifies whether to verify the remote key using DNS and SSHFP resource records. If set to yes, the client implicitly trusts keys that match a secure fingerprint from DNS. Insecure fingerprints will be handled as if this option was set to ask. If this option is set to ask, information on fingerprint match will be displayed, but the user will still need to confirm new host keys according to the StrictHostKeyChecking option.

So if the fingerprint is presented from insecure DNS (not DNSSEC validated), or if the SSHFP record does not exist, does it prompt the user? We don't want this to happen since these SSH connections are happening autonomously.

Also need to check what happens if both options are set to yes.

So the host key is verified via DNS. If the fingerprint is correct it will connect. If it is incorrect, it will follow the StrictHostKeyChecking option, which when set to yes will refuse to connect to a host if its host key has changed.

If a host key is verified through DNS, is it still added to known_hosts? 
No, the host keys are only stored in the SSHFP records. This also means that when the host key is rotated, the SSHFP record needs to be updated once rather than having to amend the known_hosts file on every server that has ever connected.

SSH Host Key Rotation
---

How do you rotate SSH host keys and update the SSHFP records in DNS(SEC)?

Requirement for renewal is initiated every x days/weeks
host generates new host keys
host connects to control machine, provides the new SSHFP values and asks for hosts SSHFP records to be updated
control machine updates DNS zone info with new SSHFP values
if update is successful, remove old values and resign zone. Inform host to remove old host keys
if update is unsuccessful, remove new values and report error.


SSHFP records are available as puppet facts. So if the puppet master is using puppetdb to store fact data, the SSHFP record for every node is stored and is available to query. This could be queried and then used to build up zone record data and published in DNS. Host key rotation could then be achieved by the nodes generating a new key, syncing facts with the puppet master which then in turn updates the DNS records.



Setting up IPsec Problem:
---

### Problem Statement

How do we set up IPsec between the control machine and machines it creates?

How do we set up IPsec between the router and machines communicating with it?

How do we set up IPsec between the router and other sites?

Assigning IP addresses to jails
---

It is not possible to assign IP addresses to jails using DHCP, they can only be assigned via jail.conf. This introduces the issue that a human would be required to find out a free address and manually enter it into the jail.conf, which becomes additionally complex with long and hard to remember IPv6 addresses. Some of this problem can be mitigated using variables for example by having the subnet prefix as a $PREFIX variable which can then be referenced as e.g. $PREFIX::d3d8. 

Another method available is the ip_hostname parameter in jail.conf which resolves the host.hostname parameters in DNS and all addresses returned by the resolver are added for the jail. So instead of entering the IP into jail.conf, a AAAA record would be manually entered into DNS and the jail would pick it up from there. 

Since only applications that require an external IP address are hosted inside jails, those applications should have a known IP address. This would be services like DNS, which needs a static and human-known IP address. These IP addresses could be hard coded into the DNS record available at the temporary DNS server (unbound) hosted on the control machine which is available during initial bootstrapping. The jails would then use the ip_hostname parameter to lookup their hostname in DNS, from which they would assign the jails IP address. Subsequent hosts would generate their IP address via SLAAC and DNS would be updated via puppet as normal.

Giving DNS server information to clients
---

Rather than manually configuring /etc/resolv.conf for the location of the local DNS servers, this information can be provided either by the router or DHCP server. If you do not want to run a DHCP server and rely solely on SLAAC for address allocation, then you can have the router provide the DNS information. Otherwise, the DHCP server can provide the DNS information. [RFC8106]

[RFC8106]: https://tools.ietf.org/html/rfc8106

The major benefit of this approach is that you do not have to make any manual configurations for the location of the DNS servers on any of your clients. However, one of the drawbacks is experienced during the initial bootstrap when the DNS servers do not yet exist. So the DNS servers will need to have their stub resolvers configured manually.

Since we have a robust DNSSEC implementation available, it makes sense to store as much crypto/public keys in there as possible rather than having them spread over multiple mechanisms. So rather than TLS certs in 3rd party PKI, SMIME certs in LDAP, SSH host keys in known_hosts files and IPsec public keys distributed manually, you can have TLSA, SMIMEA, SSHFP and IPSECKEY Resource Records stored securely in DNS.

It is also important for us to have this information in DNS so that it can potentially be referenced by other organisations. If another org needs to access a website, it needs to be secured with TLS which is validated by the TLSA record via DANE. Likewise, if a person in another organisation wants to send an email, they need to know the TLS cert to secure the TLS communication and also the SMIME certificate to encrypt the email itself. By publishing the TLSA record and SMIMEA records in DNS, the other organisation can access this information and be confident that the records are accurate.

IP addresses that need to be known by a human
---

- Router(s)
- Control Machine(s)
- DNS servers



Resource records to be stored in DNS(SEC):
---

Static:

- DNS servers
- Hostname to static IP for infrastructure servers
- CNAMES for standard services (auth.example.com, dns.example.com)
- MX records

Dynamic:

- Hostname to dynamic IP for app/other servers
- SSHFP records
- IPSECKEY records
- TLSA records (for all web/app servers)
- SMIMEA (for each user)


Ensure packages and services continue working after OS / package updates
---

It would be preferable to have updates to the OS and packages to be downloaded, tested, and applied automatically. Usually this is one of the tasks of systems administrators, and is often carried out at regular intervals and applying updates all at once. This also goes against the immutable infrastructure paradigm that is often employed in cloud infrastructures. 

Using continuous integration tools and configuration management tools in parrallel will allow us to perform these actions autonomously. 

Very often, you can subscribe to mailing lists which announce when OS or package updates are released. CI tools like Builtbot can listen for these emails, and run specific actions based on the content. For example, when new security updates for the kernel or base are released, an email would be sent and received by Buildbot which would then kick off the patching of  servers in the test environment. Once tested and the applications are confirmed to be working ok, then the patches can be applied to other environments. 

Likewise if a new major version is released, an email is received, Buildbot then runs through the process of creating a new zfs boot environment on servers in the test environment and applies the new major version to the new BE. After rebooting into the new environment, tests are performed to check that the application still works ok. If so, the major version is rolled out to other environments. This ties in with the need for redundancy, because we would need to take a server out from the load balancer to perform the upgrade and put it back once tested and working. 


By creating infrastructure acceptance tests using tools like testinfra, we can easily validate that packages, services and configuration files continue to work in the same way before and after upgrades take place. It also gives us the opportunity to practice test-driven infrastructure, by first creating the test then the code to actually implement the change. These tests will also contribute to cross OS compatibility because the same tests can be run on different OSes.

Cross OS init/service compatibility
---

Init systems vary wildly across different operating systems. FreeBSD has a sane init system based on shell scripts that is incredibly easy to port to other OSes, but this is not true for systemd and the like. One option is to use daemontools by djb which has packages on most OSes and is designed specifically to be cross-OS compatible. 

It can also use shell scripts, so it may be possible to just copy the FreeBSD service scripts and use them with daemontools but this needs testing.


Bootstrap
===


Version Control
---

There are a number of options including git and subversion. Choose the tool that is best suited to your organisation. git has been chosen as it is open source, familiar to most people and easy to pick up.

Since Git is a collaborative tool, it is common to install a web version of git such as GitLab or Gogs to give people a GUI. This is organisation specific, for our use case we will just have git repos stored on a specific server/storage area. All of the tools available to git are usable in the git package.

Modern configuration management systems have the ability to use git repositories as backends for their configuration files. This allows a workflow of only ever updating files that exist in version control which means changes are entered into history and can be audited.




git package installed
/usr/local/git ? contains repos
depends on ssh infrastructure
separate user accounts are used for specific projects
machines access these accounts with their specifically generated ssh key pair, with the public key put into the authorized keys of the user for the project

salt-repo authorized_keys:
  salt-master01 public key 
  salt-master02 public key 

hugo-repo authorized_keys:
  hugo-master01 public key
  hugo-master02 public key

These service account users have git-shell as their shell, which means they can only push/pull.

SSH
---

The default for HostKey is to accept RSA, DSA, ECDSA and ED25519 host keys. We only want to use ED25519, which can be enabled with:
HostKey /etc/ssh/ssh_host_ed25519_key

We need to have the capability to rotate the host key. The old and new keys both need to be accepted until the new keys SSHFP resource record has been published into DNS.

So to rotate the host key:

- Generate a new host key
- Update the /etc/ssh/sshd_config file to specify the name of the new host key, while keeping the existing host key defined as well
- Calculate the SSHFP resource record of the new host key
- Update the zone file with the SSHFP record
- Resign the zone 
- Publish the zone
- Update the /etc/ssh/sshd_config file to remove the old host key

he node itself should be responsible for generating the new host keys so that the private keys are not transported across the network. Using Saltstack's [Event-Driven Infrastructure] model we can detect when a new host key is generated and automatically perform the steps required to update the zone with the new SSHFP record. 

[Event-Driven Infrastructure]: https://docs.saltstack.com/en/getstarted/event

The default for AuthorizedKeysFile is to use the .ssh/authorized_keys file in the users home directory. 
AuthorizedKeysFile .ssh/authorized_keys

Like host keys, user keys should be rotated regularly. For service accounts, the rotation can follow a similar process to host key rotation.

- Generate a new user key
- Update ssh_config to use the new key, while keeping the existing user key defined as well
- Grab the public key, and update the authorized_keys files on machines as necessary
- Once updated, update the ssh_config file to remove the old user key

We will keep this default, but the way that users connect may be slightly different than what is normally expected. For example, on a git server we may have a particular user account created to allow access to a repository. It is likely that this same repository would be accessed by many different machines to pull down their configuration. Rather than creating a separate user account per machine on the git server, we would create one account called git-repo or something, then the authorized_keys file for that user would contain the public keys of multiple machine users. So the master01 machine would have a git-repo user as well, but its SSH keys would be different to the git-repo users SSH keys on the master02 machine. But the public keys of the git-repo user of both master01 and master02 would exist in the authorized_keys file on the git server.

!! none of that makes sense and needs rewriting !!


machines access these accounts with their specifically generated ssh key pair, with the public key put into the authorized keys of the user for the project

salt-repo authorized_keys:
  salt-master01 public key 
  salt-master02 public key 

hugo-repo authorized_keys:
  hugo-master01 public key
  hugo-master02 public key

The SSH keys used by humans to directly connect to servers are harder to manage, since we would probably want the private keys to be encrypted and require a password or preferably include two-factor authentication as well. So its harder to automate the rotation. It may be best to instead have a MOTD that encourages the user to update their SSH key. It could give a time period that the user needs to have changed their keys by, and dynamically update the MOTD to say if the keys are "expired". If we were really strict, we could block log in at this point. However, the infrastructure is supposed to be hands-off and there should only be a requirement for a human to log into a server directly if things have gone wrong. So we dont really want to block human access.

Required SSH accounts / connections

- git pull/push - config management and application repos
- zfs send/recv - upgrading zfs boot environments. application deploys via zfs/jails
- human user accounts - human access to servers



Implementation
===

Throughout this design it assumed that the infrastructure is built on bare metal by default, though it is acceptable that multiple services may be running on the same physical host and segregated using jails or virtual machines. Cloud infrastructures are not considered because they are inherently hosted externally which is not possible in a secure environment.


Provisioning
===

IPv6
---

### Address Autoconfiguration (SLAAC) ###

### SEND ###

### SEND SAVI ###

### DHCPv6 ###

### IPsec ###

OS
---

### FreeBSD ###

While NanoBSD was considered in the past, zfs boot environments are now used.

With zfs boot environments, we can download the updated base files, create a new boot environment, start it in a jail, apply our configuration, test it, and then replicate the zfs dataset to other hosts using zfs send/recv over SSH. This gives us a reliable method of upgrading hosts and also minimises the amount of traffic over the internet. We would only need to download the base files once and then distrubute them locally rather than each host downloading updated versions. 

Likewise, any packages that are required for our infrastructure to work should be download onto a local package mirror/cache. This means we can still function if the internet connection is unavailable and allows us to ensure we are using the latest versions of packages.

### Jails ###

### ZFS ###

### Host Install Tools ###

### Ad-Hoc Change Tools ###

Configuration Management
===

DNS
---

### DNSSEC ###

### DANE ###

### DANE/SMIMEA for Email Security ###

### S/MIME or PGP ###

Kerberos
---


NTP
---

### NTPsec ###


App Deployment
===

Application Servers
---

### NGINX ###


Security and Compliance
===

Security and Crypto
---

### TLS ###

### SSH ###

### HSM ###
### Passwords ###
### TCP Wrapper ###
### IDS ###
### Firewalls ###

Configuration Management Tools
---

Authorisation / Access Control Lists
---

Role-Based Access Control / Shared Administration (sudo)
---

Domain Naming Service
---

Directory Service (LDAP)
---

Time Service
---

Logging / Auditing
---

RPC / Admin service
---

Orchestration
===

Specific Operational Requirements
---

### Configuration ### 

### Startup and shutdown ### 

### Queue draining ###

### Software upgrades ###

### Backups and restores ###

### Redundancy ###

### Replicated databases ###

### Hot swaps ###

### Access controls and rate limits ###

### Monitoring ###

### Auditing ###

Unspecific Operational Requirements
---

### Assigning IPv6 Addresses to Clients ### 

### Static or Dynamic IPv6 Addresses (DHCPv6 or SLAAC) ###

### IPv6 Security ###

### Hostname Conventions ###

### Choosing an Operating System ###

### Choosing a Configuration Management Tool ###

### Scheduling with cron ###

Scaling
===

User Access
===
