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

* __Azure Blobs__ - Scalable, Object-orientated storage for modern cloud apps. A container for unstructured data. Holds images, videos and binaries
* __Azure Queues__ - Messaging and integration service. For loosely coupled solutions. Micro-services. Sends messages between different components of the solution.
* __Azure Files__ - Replaces traditional files sharing service. Like a File Server (F&P) in the cloud.
* __Azure Tables__ - Simple storage for non-relational semi-structured data. Solution for storing key/attribute data. Simple DB like.

| Property         | Description                      |
| ---------------- | -------------------------------- |
| Account Kind     | Features and pricing. V1 and V2  |
| Performance Tier | Performance characteristics      |
| Replication      | Redundancy and high availability |
| Access Tier      | Affects pricing. Hot or cold     |
