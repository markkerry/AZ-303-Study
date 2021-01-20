# Implement and Manage Azure Infrastructure

## Azure AD

Identity Management - users, groups and other metadata

Enterprise Access Management - apps, SSO, device management

Identity and Access Security - MFA, just-in-time access, identity protection, risk monitoring

### Implementing Azure AD

AAD can build a trust relationship between it and Azure Subscriptions and Office 365. Azure AD is the tenant and the single source of truth. First create with an initial _yourdomain_.onmicrosoft.com then add a custom domain using __TXT__ or __MX__ DNS records to verify that you own that domain. Note that it is important to create it in your local region for data sovereignty. Then you create an association/trust relationship with one or more Azure subscriptions.

To add a custom domain go to __AAD__ -> __Custom domain names__ -> __Add custom domain__ -> Enter the name. Add a TXT or MX record. Copy the __Destination or points to address__ info, open your DNS registrar create a new TXT record. The value is the __Destination or points to address__. Also copy in the TTL from Azure into DNS. After adding TXT to DNS go back to Azure and click Verify. Set the new custom domain as the primary.

There is a difference between __switch__ and __change__ directories. Switch will allow you to view that AAD tenant, authenticate to it, and manage the azure subscriptions within that directory/tenant. Change directory changes the subscription's association with that tenant/directory. Do not do without planning as affects RBAC among other things.

## Virtual Networks

Virtual Networks (VNet). Isolated within Azure

Subnet. VNets have one or more subnets.

Address Space. VNet has one or more address spaces. E.g. 10.1.0.0/16 for the VNet address space. Subnet1 with 10.1.1.0/24 and Subnet2 with 10.1.2.0/24 in the VNet. Microsoft will reserve .1, .2, and .4 IP address and well as .255. So the first IP in the subnet will be 10.1.1.4 and last will be 10.1.1.254

Smallest subnet allowed is /29 and largest is /8.

Custom DNS can be configured. DHCP is built in for the subnet, but custom DHCP cannot be deployed.

Can be integrated with ExpressRoute, Private Link and VPN.

System routes are default routes configured by Azure. By default any subnet in VNet has a route configured to the internet. There will also be connectivity between subnets. Go to the NIC of the VM to see the __Effective Routes__. There you will see a prefix of 0.0.0.0/0 and next hop to the internet. That's effectively a wildcard which means if the address prefix is not defined in the effective routes, send the traffic to the internet.

Custom routes are user-defined routes which allow custom paths of communications to be enforced or blocked. Allows to block internet access from a particular subnet, or force traffic to an Azure Firewall. Create a __Route Table__ resource in Azure to define custom routes. Block internet would be 0.0.0.0/0 and next hop set to __none__. Then associate that route with a subnet. If you wanted to specify that all google DNS bound traffic goes through a virtual appliance you would do the following. Create a route, prefix of 8.8.8.8/32, next hop is virtual appliance, then IP of that appliance. The NIC of those machines need to then have IP forwarding enabled. Other things which will add to the route table is VNet Peering, Service Endpoints and ExpressRoute (BGP)

A Custom Route table will override any System (default) routes. Order of priority = Custom > BGP > System. Also the longer the prefix will override a shorter one. E.g. 10.0.0.0/32 will match more closely than 10.0.0.0/24.

## Virtual Machines

Considerations for VM sizes:

* CPU allocation
* Total memory
* Graphics capabilities
* NIC performance
* Storage performance
* Influences limits (max NICs, disks)

VM sizes can be changed after creation but require a restart. Available sizes depend on whether the VM is running or the location of the VM. If the machine is running you will only see available sizes from the underlying hardware that machine is running on. If you deallocate the VM, more sizes may become available. Some regions also do not have all Compute and GPU machines available.

| VM Size Type      | Description                                                                                                      |
| ----------------- | ---------------------------------------------------------------------------------------------------------------- |
| General Purpose   | Balanced CPU-to-memory ratio. Ideal for test/dev. small-to-med DBs, and low traffic web servers                  |
| Compute Optimised | High CPU-to-memory ratio. Good for med traffic web servers, network appliances, batch processes, and app servers |
| Memory Optimised  | High memory-CPU-ratio. Relational DBs, med-to-large caches, in-memory analytics                                  |
| Storage Optimised | High disk throughput and IO. Big Data, SQL, NoSQL, data warehousing                                              |
| GPU               | Heavy GPU rendering, model training. Single or multiple GPUs                                                     |
| HPC               | Fastest, most powerful CPU VMs with optional high-throughput network interfaces (RDMA)                           |

Some machines may also be unavailable if you have exceeded your Subscription's usage and quota limit which has been set by Microsoft. A request to increase has to be raised.

### Stop and Deallocate a VM

```python
az vm stop -g rg-eu-vms -n vm1
az vm deallocate -g rg-eu-vms -n vm1
```

## Virtual Machine Storage

__Unmanaged__
Requires manual management via a storage account. Limited support for high availability.

__Managed__
Not responsible for configuring storage accounts. High availability. Focus going forward will purely be on managed disks.

| Disk Type      | Description                                                                                 |
| -------------- | ------------------------------------------------------------------------------------------- |
| OS Disk        | Required by all VMs by default                                                              |
| Temporary Disk | Local disk to the Microsoft infrastructure hosting the VM. Not persistent                   |
| Data Disk      | Disk used to store persistent info, such as app data                                        |
| Ephemeral Disk | Special OS disk which contains OS install, but data can't be changed. VDI persistent images |

__Disk Caching__ (Host Caching) feature that leverages high performance read and write storage systems for very fast access.

__BlobCache__ is leveraged by Disk Caching, which uses a combination of host SSDs and memory to provide to VMs

__Cache Options__
__Read/Write__ - Leverages a cache for both read and writes. Both read and write operations have improved performance Enabled by default on OS disks and supports Data Disks. App on the VM must support it to ensure data is correctly persisted from cache to storage.
__Read-Only Cache__ - Improves read performance (throughput and latency) by reading from cache, but all writes to direct to storage.
__None__ - Both read/write goes direct to storage.

### Performance Tiers

* __Ultra__ - Extremely high input/output e.g. SAP HANA, Top tier DBs
* __Premium SSD__ - High performance prod workloads
* __Standard SSD__ - Light-usage apps, web dev and test workloads
* __Standard HDD__ - Backup and non-prod

## Azure Storage

The following services are available to __Storage Accounts__:

* __Azure Blobs__ - Scalable, Object-orientated storage for modern cloud apps. A container for unstructured data. Holds images, videos and binaries. Accessible through HTTP and REST
* __Azure Queues__ - Messaging and integration service. For loosely coupled solutions. Micro-services. Sends messages between different components of the solution.
* __Azure Files__ - Replaces traditional files sharing service. Like a File Server (F&P) in the cloud.
* __Azure Tables__ - Simple storage for non-relational semi-structured data. Solution for storing key/attribute data. Simple DB like.

| Property         | Description                      |
| ---------------- | -------------------------------- |
| Account Kind     | Features and pricing. V1 and V2  |
| Performance Tier | Performance characteristics      |
| Replication      | Redundancy and high availability |
| Access Tier      | Affects pricing. Hot or cold     |

| Account Kind               | Description                                      |
| -------------------------- | ------------------------------------------------ |
| GPv2                       | Recommended for blobs, files, queues, and tables |
| GPv1                       | Legacy for the above                             |
| BlobStorage                | Legacy only supports blobs                       |
| BlockBlobStorage (Premium) | Blob only type, premium performance tier         |
| File Storage (Premium)     | Files only type, premium performance tier        |

| Performance Tier | Description                            |
| ---------------- | -------------------------------------- |
| Standard         | Default with speeds for most workloads |
| Premium          | High performance specific workloads, GPv1 & 2 for unmanaged disks and page blobs only, BlobStorage not supported, BlockBLobStorage is block and append blobs only, FilesStorage for files only |

| Replication                       | Description                                                                |
| --------------------------------- | -------------------------------------------------------------------------- |
| Locally-redundant Storage (LRS)   | Synchronous Replication to three other scale units within region. Low cost |
| Zone-redundant storage (ZRS)      | Synchronous Replication to three availability zones within region          |
| Geo-redundant storage (GRS)       | Asynchronous Replication to a secondary region                             |
| Geo-zone-redundant storage (GZRS) | Combination of ZRS and GRS                                                 |

| Access Tier | Description                                                                  |
| ----------- | ---------------------------------------------------------------------------- |
| Hot         | Best for when data is modified more frequently                               |
| Cool        | Cheaper than hot when data is modified less frequently                       |
| Archive     | Cheapest storage for when data can remain offline for longer periods of time |

### Storage Account Connectivity

1. __Public Endpoints__ - Publicly accessible endpoint
2. __Firewall__ - Storage Account Firewall to restrict access to all services within a storage account. Network Level Access.
3. __Network Integration__ - Services such as Service Endpoints, Private Link allowed to access the Azure Storage Services.

Each service (Files, Queues, Tables, blobs) each have a __Default Public Endpoint__. A DNS entry

| Service | Default Service Endpoint      |
| ------- | ----------------------------- |
| Blobs   | saname.blob.core.windows.net  |
| Queues  | saname.queue.core.windows.net |
| Tables  | saname.table.core.windows.net |
| Files   | saname.file.core.windows.net  |

E.g.
StorageAccountName.ServiceName.core.windows.net/ContainerName/BlobName
saname.blob.core.windows.net/container1/test.txt

__Storage account firewall__ to lock down to specific locations. Block all access by default then create an allow rule to allow specific IP address/location.

Select the __Storage Account__ -> __Firewalls and virtual networks__ -> select __Selected Networks__ -> click __Save__.
Can create exceptions such as _Allow trusted Microsoft services to access this storage account_. Or _Allow read access to storage logging from any network_, or _Allow read access to storage metrics from any network_. Can also add a CIDR to allow access or a Virtual Network.
Applying at the Storage Account level applies to all services in that storage account.

### Storage Account Security

Can configure Access Controls to specify permissions. Layers to configure:

* Data Layer. Access to the data in the SA. E.g. User access to files and folders, Web client access to images and objects, Application service access to messaging
* Management Layer. Access to perform management tasks. E.g. Changing SA properties, changing permissions of the SA.

| Access Control                   | Description                                                                    |
| -------------------------------- | ------------------------------------------------------------------------------ |
| Access Keys  | Least secure. Provides full management and data layer access. Only recommended for service applications to generate a SAS. Access keys can be regenerated and revoked |
| Shared Access Signatures (SAS)   | Provides access to one or more services in a SA                                |
| Role Based Access Control (RBAC) | Control permissions of an AAD identity for SA management and data layer access |

__NOTE:__ Not best practice to use __Access Keys__. Prefer __SAS__ instead. If you regenerate an access key, all of the SAS keys generated by that access key will also regenerate. Generating a SAS will allow you to define which service(s), permissions (read/write/delete), start and expiry time, allowed IP, protocol and signing key.

__SAS Example__ https://myaccount.blob.core.windows.net/pictures/profile.jpg?sv=2012-02-12&st=2009-02-09&se=2009-02-10&sr=c&sp=r&si=YWJjZGVmZw%3d%3d&sig=dD80ihBh5jfNpymO5Hg1IdiJIEvHcJpCMiCMnN%2fRnbI%3d

Breakdown:
_container/blob_ https://myaccount.blob.core.windows.net/pictures/profile.jpg?
_Signed Version_ sv=2012-02-12&
_Signed Start_ st=2009-02-09&
_Signed Expiry_ se=2009-02-10&
_Signed Resource_ sr=c&
_Signed Permission_ sp=r&
_Signed Identifier_ si=YWJjZGVmZw
_Signature_ sig=dD80ihBh5jfNpymO5Hg1IdiJIEvHcJpCMiCMnN%2fRnbI%

Access Policy - Like a SAS but more of a parent SAS. Server side. SAS is client side. Parent SAS (Access policy) can create a SAS. Can then from client side remove or revoke access policy (Inc SAS). Such as from the Storage Explorer GUI.

### Blob Architecture

__Storage Account__ contains the __Blob services__ -> __Container__ is where blobs are stored. Can have multiple containers -> __Blobs__ are actual pieces of data
Three different blobs:

1. Block Blob - Optimised for streaming content, for images and videos etc.
2. Append Blob - Constant write to such as log files
3. Page Blob - VM Disk. Random read/write operations.

In blob storage there is no true folder hierarchy. Flat file system, a bucket of objects. Can create Virtual folders from Storage Explorer. Looks like but not a real folder. It basically gives the file a prefix. E.g Folder1 contains File1.txt. The actual name of the file becomes Folder1/File1.txt.

In the container you can select to Change the Access Level. The levels are

* Private - No anonymous access
* Blob - Anonymous read access for blobs only
* Container - Anonymous read access for containers and blobs

Static websites can be created in Storage Accounts. In SA select Static Websites -> Enabled -> Index document is index.html. This creates a Primary endpoint URI and a $web container. Then in the SA create a Custom Domain to change the Primary endpoint URL from the default. You must own the domain name and enter a CNAME in your DNS for the SA primary endpoint.

### Azure Files

MS online version of an on-premise file server. Fully managed file sharing with true folder structure hierarchy. Designed for SMB protocol. Extended by __Azure File Sync__ allows users to connect to a Windows File Server which has its data synched from __Azure Files__ services.

__Azure Files__ Architecture is __Storage Account__ -> __Files Shares__ -> Files and Folders.

Different from blobs. Blobs have a virtual folder hierarchy. Files has a true folder hierarchy.

Open SA -> File Shares -> New Share -> name and set quota -> Set IAM -> configure snapshots (Backups) -> Can connect via the PowerShell script provided in Azure.

Can connect to File Shares using SMB 2.1, SMB 3.0+, and REST/HTTP. But there are conditions. If you are within the same region as the Azure Files shares, you can use REST and SMB 2.1/3.0 protocols. If outside of the reason can only use REST and SMB 3.0 as you can ensure connection is encrypted in transit. Account Keys and SAS can only be used via REST. Account Keys and Azure AD Domain Services can be used via SMB.

Before creating Files Shares you should open the configuration of the SA and set __Secure transfer required__ to __Enabled__

Map a drive to a File Share

```powershell
$connectTestResult = Test-NetConnection -ComputerName azlabfjgzpeqc74qv4.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"azlabfjgzpeqc74qv4.file.core.windows.net`" /user:`"Azure\azlabfjgzpeqc74qv4`" /pass:`"G/2b/fqfhDK/5Mxylr2jsGqH3KWIFbNQWMWcG4+hMrp9Bp5gwPFuuxM4dOvywlJtMIrYf2JEOtgmhLhMzjWGDQ==`""
    # Mount the drive
    New-PSDrive -Name Z -PSProvider FileSystem -Root "\\azlabfjgzpeqc74qv4.file.core.windows.net\companydata" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}
```

## Virtual Networks Continued

### VNet Peering

When "peering" VNets to establish connectivity between them, this is __NOT__ going over the public internet. It's over the Microsoft backbone. It's low-latency, high bandwidth connectivity. You no longer have to create the peering in one direction, then complete the peering in the other direction. Now can do it in same wizard.

Example:
__Name of peering from vnet1 to vnet2__
vnet1-to-vnet2-peer
Select: vnet2
__Name of peering from vnet2 to vnet1__
vnet2-to-vnet1-peer

Benefits:

* Connectivity via Private IP
* Supports cross-subscription connectivity
* Supports cross-region connectivity

Limitations:

* IP Address space cannot overlap
* Does not support transitive routing. vnet1 peered to vnet2 cannot talk to vnet3 through vnet2. Requires its own peer or a network virtual appliance (router) in vnet2

### Peering Advanced Configuration

Can create a Hub and Spoke connection. vnet1 (Spoke) can connect to vnet3 (Spoke) through vnet2 (Hub). A NVA would sit in vnet2 and have Allow Forwarded Traffic enabled. And for a an on-premises network connection via a VPN Gateway, in order for vnet1 to connect to the on-premises you'd have to enable Allow Gateway Transit on vnet2 for traffic to go through it.

More info:

* Allow Forwarded Traffic. Allows forwarded traffic to pass through VNet peer. Commonly used with Azure Firewall.
* Allow Gateway Transit. Allows a VNet to be used to access other resources through a VNet gateway e.g. on-premises network to a spoke VNet and vice versa.
* Use Remote Gateway. Configures a VNet to make use of a peered VNet's gateway, to access other resources.

### VPN Gateways

Can be used instead of peering to establish connectivity between VNets. They have their own subnet called __GatewaySubnet__. Each Gateway subnet in say vnet1 and vnet2 will be assigned Public IP addresses to establish the connection. Enabled over IKE site-to-site VPN tunnel ensuring all traffic is encrypted. VPN gateway was designed be used for site-to-site (on-premise to Azure) or point-to-site (laptop to Azure) connections.

### Service Endpoints

Private connectivity, over the MS backbone to azure services from your resources in your private VNet. Public accessibility can be blocked with services firewalls (e.g. Storage Account firewall).

Service Endpoints are created on the subnet level not VNet you are effectively creating a route. They are not given private IPs, only the route to them changes.

Open a VM within that subnet, open their NIC, select effective routes. Here you will see the service endpoint.

Once you have created a service endpoint for storage accounts in the subnet, you can (optional) open the storage account, open __Firewalls and virtual networks__, change it from All networks to __Selected networks__ and add the VNet and subnet for the subnet which has the service endpoint route in.

### Private Link

Provides private IP addressing within a VNet to access supported services. Ensures traffic between resources in VNet and connected services only traverses the secure MS backbone. Improved accessibility from on-premises and globally.

The difference also is with service endpoints you point to the service at a really high level. With Private Link you can be more granular and point to a specific resource. E.g. a blob in a SA.

Private Link also works cross regions.

1. First you deploy a __Private Endpoint__ in your VNet. This is a network interface that connects to a supported service. It receives a private IP from the registered subnet and configured with DNS.
2. The __Connected Resource__ is the scoped Azure PaaS resource associated with a Private Link
3. The __Private Link Service__ is a customer-managed service operating behind a standard load balancer, enabled for Private Link accessibility.

After you have created a Private Endpoint in your Storage account, given the private link a name, select the same region, select Microsoft.Storage/storageAccounts, then select the VNet and subnet. Leave the DNS info as is and the FQDN of the Private Link.

From my machine:

```terminal
nslookup azurelalabszvhxkvmdyfqm.blob.core.windows.net
Server:  dns.google
Address:  8.8.8.8

Non-authoritative answer:
Name:    blob.blz22prdstr01a.store.core.windows.net
Address:  52.239.155.132
Aliases:  azurelalabszvhxkvmdyfqm.blob.core.windows.net
          azurelalabszvhxkvmdyfqm.privatelink.blob.core.windows.net
```

From VM1 on same subnet:

```terminal
nslookup azurelalabszvhxkvmdyfqm.blob.core.windows.net
Server:  UnKnown
Address:  168.63.129.16

Non-authoritative answer:
Name:    azurelalabszvhxkvmdyfqm.privatelink.blob.core.windows.net
Address:  10.1.1.5
Aliases:  azurelalabszvhxkvmdyfqm.blob.core.windows.net
```

## Virtual Machines Continued

### Availability Sets

* Protecting against planned and unplanned outages.
* It protects redundant VMs which serve the same purpose.
* Manage the distribution of VMs across infrastructure
* Protect against VM host infrastructure failure.
* Protect against VM host infrastructure maintenance.

Unplanned - Fault domains (hardware failure)
Planned - Update domains (platform updates)

__Fault Domains__ - Ensures VMs do not share same power or networking. Up to 3 allowed (0, 1, 2)
__Update Domains__ - Logical grouping of infrastructure which can be restarted for platform updates. (one at a time). Up to 20 allowed (0 - 19)

| Name | Fault Domain | Update Domain |
| ---- | ------------ | ------------- |
| vm01 | 0            | 0             |
| vm02 | 1            | 1             |
| vm03 | 2            | 2             |
| vm04 | 0            | 3             |
| vm05 | 1            | 4             |
| vm06 | 2            | 0             |

Servers is an availability set should all serve the same purpose. E.g. 3 Web tier servers. The AS needs to be created before the VMs. You cannot deploy existing VMs into an AS. The VMs need to be in the same __region__ and the same __resource group__ as the AS.

A single VM in an AS will not achieve 99.95% SLA, but an AV with two or more VMs with the same purpose in will provide a 99.95% SLA. App tiers should not be mixed within an AS. Aligned Managed Disks also help protect storage against outages.

### Virtual Machine Scale Sets (VMSS)

Scale Out - add more VMs which serve the same purpose
Scale In - Reduce the number of VMs
Scale Up - Up the VMs resources
Scale down - Reduce the VMs resources

VMSS simplify the management and configuration of auto-scaling VMs. Need a definition of what the machine needs to look like.  Rules which determine when and why your solution will scale, both in and out.

__VM Definition__ - All instances within the VMSS are built according to the same VM definition, size, OS, NICs, region, etc. Can use custom image so machines is configured as soon as powered on. e.g. fully patched, IIS/Apache installed etc.

__Autoscale definition__ needs to be set.
Condition: When and why autoscale will trigger. E.g. CPU above 80%
Direction: Scale-in or scale-out. E.g. Out
Response: Action to occur. E.g. Add 1 instance

__Autoscale Scale-In Policy__ - VM deletion priority during scale in. Default:

1. VMs balance across AZ
2. VMs balance across FD
3. VMs with highest ID deleted first

VMSS can be deployed across multiple availability zones, if the region you are deploying to supports it.

In the portal go to Home -> New -> Virtual machine scale set -> Select the subscription, resource group, Name the scale set, select the Region, AZ if supported.
Then select the image (can use custom which is most likely used in the real world.), Username and password.
Can then select additional managed disks.
Select the VNet and you can edit the NIC and enable a public IP address (Not likely to be needed as using a lb), select yes or no to a LB
Select the instance count (0 to create the VMSS without any instances initially), manual or custom __scaling policy__, and a __Scale-In policy__

The Scaling Policy setting windows is where you can manually specify the instance count or select Custom autoscale and specify the min/max/default numbers.
The Scale mode based on a metric can be specified in the default profile. Add a rule. Increase when __Percentage CPU__ Greater than 70% for 10 mins. Increase account by 1. Cool down (minutes) means wait x minutes for the metric to come down before scaling again.

If you create a scale out policy, you need to create a scale in policy. If CPU less than 70% for 10 minutes, decrease the count by 1.

You can also create an autoscale profile based on a fixed time/date. E.g peak times. Also a Repeat specific days can be set. E.g. every Saturday and Sunday.

If you have multiple scaling profiles configured, they will be evaluated in the following order.

1. Fixed date profiles
2. Reoccurrence profiles next
3. Regular profiles last

If you have multiple autoscaling profiles. They will be evaluated in the following order:

1. If you have multiple scale out rules, it will always scale out the to maximum scale out specified in those rules
2. If you have multiple scale in rules, it will always scale in the to maximum scale in specified in those rules

### VM Dedicated Hosts

Dedicated physical host infrastructure for your VMs if you do not want to share it with other customers. A per subscription configuration. It provides more control over the maintenance, e.g. patching, reboots. Helps meet compliance requirements due to isolation. Can leverage on-premise software licensing agreements to reduce costs, e.g. Windows Server, SQL licenses.

In the portal create new Dedicated Hosts -> enter the name, resource group, subscription and region -> select the Size family e.g. __Standard DSv3 Family__
The Host group -> create new -> name it -> select FD count (3) -> choose the FD -> select yes or no to Save Money on licensing.
__NOTE:__ This will cost you money even if you do not deploy any VMs to it because you have reserved a host.
After it is created go to instances and Add VMs. The VMs you create must match the configuration of the dedicated host e.g. image family, region. In advanced tab select the host group you created.

### Azure Disk Encryption

Encryption of data on Managed Disk volumes. Different from Storage Service Encryption which is how Storage Accounts are encrypted. Azure managed disks do ultimately end up on Azure Storage Service. Storage Service Encryption is encryption of the physical hardware, if stolen would not be accessible. Azure Disk Encryption is at an OS level if the subscription was hacked. Only the OS can access the data. It's encryption of boot (OS) and data volumes with support for BitLocker. Supports some Linux distros using DM-Crypt. It relies on Key Vault for storing encryption info. Does not support Ephemeral OS disks.

Can be enabled per VM or VMSS. A VM Extension configures OS encryption - Linux DM-Crypt and Windows BitLocker. KeyVault to encrypt, decrypt. Open the VM and the Extensions page. You will see the AzureDiskEncryption extension
