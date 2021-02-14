# Implement Management and Security Solutions

## Implementing and Managing Governance in Azure

### Azure Organisational Structure and Management

__Tagging__ - Name/value text pair. Can be applied to resources, RGs, and subscriptions. Can be used for cost management, automation, monitoring and management.

### Azure Management Groups

Efficiently manage subscriptions. Orgs will use multiple subscriptions to segregate billing and responsibilities. Management Groups allow us to better manage these subscriptions.

* Build a hierarchy that suits your org
* Apply governance conditions to multiple subscriptions:
  * Enforce Policies
  * Enforce RBAC

__Root Management Group__ - Created for you at the top of the hierarchy. Policies applied here are considered _global_. Requires AAD GA access.
__Management Group (MG) Hierarchy__ - Up to 6 levels are supported. One MG can have multiple children. One subscription/MG can have only one parent.
__Compliance__ - Supports Policies, RBAC, and auditing with Activity Logs

Azure Portal -> Management groups -> Start using Management groups -> Create new / Management Groups ID (e.g. westeurope) / Display name (e.g. MG-WestEurope) -> Select the new MG -> details -> + Add subscription

### Role-Based Access Control

Secure access to Azure resources, following the principle of least privilege. Configure permissions based on actual roles. Define the permissions that are and not allowed.

__Security Principal__ - user/group/app
__Role Definition__ - Owner/Contributor, Reader, Virtual Machine Contributor, Backup Operator
__Scope__ - Who has what access and what to: resources,RGs,Subscriptions,MG
__Assignment__ - Is the combination of all the above. E.g. SP: markkerry, Role: Contributor, Scope: rg-eu-vms

Azure Portal -> Access control (IAM) -> + Add / Role assignments -> select a role -> select user

#### RBAC Custom Roles

[Azure resource provider operations](https://docs.microsoft.com/en-us/azure/role-based-access-control/resource-provider-operations)

* Metadata (Name, ID, etc) - Details info such as name of custom role, ID, description, and whether it is a custom or built-in role
* Actions - Includes action and notActions, which define management operations that are (or are not) allowed to be performed
* Data Actions - Defines dataActions and notDataActions, which define operations the role can (or cannot) perform on data.
* Assignable Scopes - Specifies where the MG, subscriptions, or RGs this role can be assigned to

```json
{
    "Name": "Virtual Machine Operator",
    "Id": "88888888-8888-8888-8888-888888888888",
    "IsCustom": true,
    "Description": "Can monitor and restart virtual machines.",
    "Actions": [
        "Microsoft.Storage/*/read",
        "Microsoft.Network/*/read",
        "Microsoft.Compute/*/read",
        "Microsoft.Compute/virtualMachines/start/action",
        "Microsoft.Compute/virtualMachines/restart/action",
        "Microsoft.Authorization/*/read",
        "Microsoft.ResourceHealth/availabilityStatuses/read",
        "Microsoft.Resources/subscriptions/resourceGroups/read",
        "Microsoft.Insights/alertRules/*",
        "Microsoft.Insights/diagnosticSettings/*",
        "Microsoft.Support/*"
    ],
    "NotActions": [],
    "DataActions": [],
    "NotDataActions": [],
    "AssignableScopes": [
        "/subscriptions/{subscriptionId1}",
        "/subscriptions/{subscriptionId2}",
        "/providers/Microsoft.Management/managementGroups/{groupId1}"
    ]
}
```

Deploy it

```powershell
New-AzRoleDefinition -InputFile .\MyCustomRole.json
```

Azure Portal -> Access control (IAM) -> + Add / Custom role

### Azure Policy

* Enforce behaviour, standards, and compliance
* Prevent (or audit) creation of non-compliant resources
* For example: restrict the allowed VM sizes

Monitor for a condition - E.g. does the resource "location" = "West Europe", require a tag or value, deploy agent for VMs, Allowed location for RGs, Disk encryption applied to VMs

Trigger an effect - Action to occur if the condition is met. Azure policy supports a range of effects e.g. append, audit, deny, modify

Assignment - Scopes can include a resource, RG, subscription or MG

Azure Portal ->  Policy -> Definitions -> Allowed locations

```json
{
   "properties": {
      "displayName": "Allowed locations for resource groups",
      "policyType": "BuiltIn",
      "mode": "All",
      "description": "This policy enables you to restrict the locations your organization can create resource groups in. Use to enforce your geo-compliance requirements.",
      "metadata": {
         "version": "1.0.0",
         "category": "General"
      },
      "parameters": {
         "listOfAllowedLocations": {
            "type": "Array",
            "metadata": {
               "description": "The list of locations that resource groups can be created in.",
               "strongType": "location",
               "displayName": "Allowed locations"
            }
         }
      },
      "policyRule": {
         "if": {
            "allOf": [
               {
                  "field": "type",
                  "equals": "Microsoft.Resources/subscriptions/resourceGroups"
               },
               {
                  "field": "location",
                  "notIn": "[parameters('listOfAllowedLocations')]"
               }
            ]
         },
         "then": {
            "effect": "deny"
         }
      }
   },
   "id": "/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988",
   "name": "e765b5de-1225-4ba3-bd56-1ac6695af988"
}
```

An __Initiative__ is a collection of policies bundled and deployed in one deployment

### Azure Blueprints

Centralised management of repeatable solutions. They provide a way for architectural patterns/designs to be defined and used repeatedly. Features for:

* Declaring environment setup using artefacts
* Defining required RGs, templates, policies, and role assignments to be used

Using Arm can deploy the resources, configure RBAC, and assign Azure policy.

__Blueprint definition__ - A definition of a given environment/solution. Includes artefacts (Arm Templates, Azure Policy, RBAC, RGs)
__Publishing and Version Control__ - For a Blueprint to be used, it must be published. Publishing supports the use of version control to better manage artefacts and definitions
__Assignment__ - Building something with a Blueprint creates an assignment. Provides an audit trail

Azure Portal -> Blueprints -> New Definition

### Azure AD Access Reviews

Provide a simplified approach to manage ongoing access. Key features:

* Removing access which is not longer required
* Self-service to reduce IT admin workloads
* Management of AAD and resource access

#### Implementation

__Onboard the AAD tenant__ - Onboarding provides admin consent for the use of Access Reviews, per tenant. AAD P2 licensing is required.
__Access Reviews__ - Supports security group and app reviews. Supports reviewers such as self, owner, etc. Access is reviewed through the Access Pane
__AAD Privileged Role Reviews__ - Supports AAD role reviews. Currently is reviewed through AAD PIM. Access is reviewed through the portal

For standard users

Azure Portal -> AAD -> Identity Governance -> create an access review -> Name it, select start date, frequency, select end date (for people to respond), add group/app, Select group owner/particular member/Members (self) for all users of group -> If reviewers don't respond remove access

For Privileged identities

Azure Portal -> Privileged Identity Management -> AAD roles -> Access Reviews -> create an access review

## VNet Security

### Network Security Groups

Control the flow of traffic across a VNet. Create rules to define what is and is not allowed. Control security at the subnet and NIC layers. Leverage priorities to define complex rules.

__Filtering Traffic__ - What traffic will we allow or deny? This includes source, source port, destination, destination port, and protocol
__Default Rules__ - NSG rules include several default rules such as "DenyAllInbound". These cannot be deleted, but can be overridden.
__Priority__ - To support different scenarios, we must define priorities for a rule. The lower the number, the higher the priority.
__Assignment__ - Assign to a NIC on a VM, or a subnet to apply to all resources within that subnet, if you assign to both they will both take effect.

When it comes to public IP addresses, the Basic SKU allows access without an NSG by default. Wen using the Standard SKU, you have to manually allow access to is via an NSG.

To create an inbound security rule for RDP:

NSG -> Inbound security rule -> Add -> Source: Any, Source port range: *, Destination: Any, Destination port ranges: 3389 (RDP), Protocol: TCP, Action: Allow, Priority: 1000, Name: AllowRDPInBound

### Augmented Security Rules

Simplifies Network Security Rules. We can more logically define security rules to match real-world solutions. Leverage __Service Tags__ for Microsoft services that are otherwise cumbersome to configure. Create and configure __Application Security Groups__ (ASG) that represent our solution network

__Service Tags__ - Represent Microsoft Services. A collection of IP address prefixes that correspond to a specific Azure service. Some of these tags include _ActionGroup_ and _ApiManagement_. These service tags can be used for inbound/outbound rules in NSGs, or Azure Firewall. Instead of you knowing all of these IP addresses MS makes it easy by giving you Service Tags to work with. MS manages the associated IPs of Service Tags as Azure services can regularly change.

Azure Portal -> vm1 -> Networking -> Outbound port rules -> Add outbound port rule -> Destination: Service Tag -> Destination service tag: Storage.WestEurope, ports 80,443

__ASG__ - Logical containers for the network interfaces used in your solution. An ASG can be used easily within NSG rules to simplify the management of security rules for a solution. They're a bit like customer managed Service Tags. All NICs for an ASG must exist in the name VNet. This is also true when an ASG is used in a rule for both source and destination. An ASG requires an NSG

Azure Portal -> vm1 -> Networking -> Outbound port rules -> Add outbound port rule (NSG) -> Destination: ASG -> Select the ASG -> Select destination ports

Now you have to associate resources to the ASG

Cloud Shell -> PowerShell

```powershell
$rgName = "rg-eu-vms"
$nicName = "vm1-NIC"
$asgName = "vm-asg"

$nic = Get-AzNetworkInterface -Name $nicName -ResourceGroupName $rgName
$asg = Get-AzApplicationSecurityGroup -Name $asgName -ResourceGroupName $rgName
$nic.IpConfigurations[0].ApplicationSecurityGroups = $asg
Set-AzNetworkInterface -NetworkInterface $nic
```

### Azure Firewall

Stateful, Fully managed firewall, purpose-built for Azure including HA and scale. Full support for Azure (VNets, availability Zones, etc). Additional network security capabilities than NSGs, such as support for FQDN filtering (outbound HTTP/S). Standard firewall rules, supporting source, protocols, destination, etc. Configure inbound DNAT and outbound SNAT network address translation (NAT) rules. Threat Intelligence with additional functionality to identify malicious IP addresses and domains. Integration with Azure Monitor logging (archive, streaming and Log Analytics).

1. Configure a VNet - This can be an existing VNet but is often a centralised VNet (hub and spoke) that is connected to your other VNets (an on-premises)
2. Configure a Subnet - The Azure Firewall must be deployed to a dedicated subnet called _"AzureFirewallSubnet"_. This subnet __must have no associated NSGs__.
3. Configure Routing - In order to have VNet resources leverage the Azure Firewall, a custom route must direct traffic to the Azure Firewall.

Azure Portal -> vnet1 -> Subnets -> + subnet -> Name: AzureFirewallSubnet -> CIDR block: small such as /26 (enough space to scale) -> NSG: none

Azure Portal -> Firewall -> Create -> RG: same as VNet/subnet -> Name the firewall -> selected region -> select existing VNet -> Firewall public IP: Add new (standard SKU, static assignment)

Azure Portal -> Firewall -> select newly created firewall -> Rules -> NAT rule collection (inbound traffic - e.g. RDP), Network rule collection (outbound traffic - Similar to NSG, port, IP, etc), Application rule collection (outbound traffic - includes FQDN tags, update.microsoft.com, or *.google.com for example)

Create a Route Table, configure a route, next hop is the private IP of the Firewall.

### Azure Bastion

Access your VMs via RDP or SSH over SSL. Azure Bastion helps simplify the security and connectivity of common management protocols. It removes the need for a public IP address for managing VMs in Azure. Continue to use popular RDP/SSH protocols over a secure SSL tunnel. Simplified deployment and security

Implementation

1. Deploy a Bastion Host - Create and deploy to a VNet. Note that a Bastion must be deployed to a subnet called _"AzureBastionSubnet"_
2. Connect to a VM - Use the Bastion option in the Azure Portal, for both both VMs and instances within a VMSS.
3. Important considerations - Connectivity requires port 443 outbound, and HTML5 support in a browser.

Azure Portal -> vnet1 -> Subnets -> + subnet -> Name: AzureBastionSubnet -> CIDR block: small such as /27 (at least)

Traffic in the subnet __should not__ be pushed through a route table (Azure Firewall), but can be assigned a NSG.

Azure Portal -> Bastions -> Create Bastion -> Create/select RG -> Name the bastion instance -> Region -> Same VNet as VMs which will use bastion -> Select the AzureBastionSubnet -> Create new public IP

Azure Portal -> Select a machine without a public IP -> Connect -> Bastion -> enter credentials -> opens in new browser windows (allow pop-ups)

## Load Balancing and Security

### Azure Load Balancer

Layer 4 traffic (TCP, UDP) distribution to multiple redundant resources, supporting HA and elasticity. Supports LB capabilities such as session affinity, and health probes. 

Key features:

__Public Load Balancing__ - Public IP, allows access from outside Azure

__Private Load Balancing__ - Internal solutions

__Availability Zones__ - Support of traffic to services that exist across the availability zones. Two modes: Basic and Standard SKUs. HA in Standard SKU

__Health Probes__ - TCP, HTTP, HTTPS probes which define the status of resources within your solution. Basic SKU is TCP and HTTP only. Standard SKU also supports HTTPS probe

__Port Forwarding__ - Configure direct, inbound access to resources that sit behind the load balancer. Can have a LB sit in between tiers so that is where you configure port forwarding. E.g. web tier to SSH into app tier via another LB.

__Outbound Connectivity__ - Control outbound connectivity (SNAT) from resources within your virtual network

Key Components:

__Frontend IP__ - LB has a public or private IP

__Backend Pool__ - The group of resources which will ultimately receive traffic from end-users

__Health Probe__ - Used for determining whether the destination instance is available

__Rules__ - Load balancing or NAT rules to configure inbound/outbound access

Azure Portal -> Load Balancer -> Name, Region -> Type: Internal (VNet private IP) or Public (PIP) -> SKU: Basic or standard (_Basic lb SKU will create basic PIP SKU and same for standard_)-> Create new PIP, Basic, dynamic

Azure Portal -> Load Balancer -> Backend Pool - Name it -> select VNet of resources -> Add the VMs or VMSS (More common)

Azure Portal -> Load Balancer -> Health Probes -> + Add -> Name it -> Protocol: HTTP -> Port: 80 -> Path: / -> Interval (seconds): 5 -> Unhealthy threshold (consecutive failures): 2

Azure Portal -> Load Balancer -> Load balancing rules -> + Add -> Name it -> IPv4 -> Select frontend IP -> TCP -> port 80 -> backend port 80 -> select backend pool -> select health probe -> Session persistence (Sticky): None, Client IP or Client IP and protocol (for sticky session to particular resource) -> Floating IP: disabled (only enable for SQL always on)

[Azure Load Balancer SKUs](https://docs.microsoft.com/en-us/azure/load-balancer/skus)

### Azure Application Gateway

Layer 7 traffic distribution for HA web apps. Provides load balancing capabilities but for web applications.

* Standard lb features
* Layer 7 functionality such as:
  * URL-based routing e.g. .../images to one pool of VMs and .../videos to another pool. of VMs
  * SSL termination, cookie-based session persistence

Key features:

__Public load balancing__ (private partially supported)

__URL Based Routing__ allows to route to different back-end pools, depending on the URL path required

__SSL Termination__ can terminate SSL/TLS as the gateway, removing the encryption/decryption overhead from back-end servers

__Session Affinity/persistence__ which is gateway managed and cookie-based. Keeps user sessions on the same server

__Web security__ features like Web Application Firewall, and HTTP header rewrite

__Autoscaling__ to scale the application up and down, based on the demands of your users/services

Key Components:

__Frontend IP__ - LB has a public or private IP associated with the application gateway

__Frontend Listener__ - IP address, port, protocol, and (if HTTPS is enabled) the associated SSL certificates that is used by the application gateway

__Backend Rule (and settings)__ - The rule brings everything together, including HTTP settings (port, persistence, path-based routing, timeout period, etc)

Azure Portal -> Application gateways -> + Add -> Name it -> Region -> Tier: Standard V2 -> Enable autoscaling -> min and max scale units: 1 and 3 -> Availability zone: No -> HTTP2: Disabled -> Select VNet -> Select AppGatewaySubnet -> Frontend IP: Public -> New Public IP -> Add backend pool -> Name it and Yes to Add backend pool without targets -> Add Routing rule -> Name the rule and the listener, leave the rest as defaults -> Backend targets choose the backend pool just created

[Azure Application Gateway V2](https://azure.microsoft.com/en-au/blog/taking-advantage-of-the-new-azure-application-gateway-v2/)

### Azure Traffic Manager

Traffic distribution for geographically resilient solutions. Leverages DNS to facilitate traffic distribution. Provides many different routing methods, and supports several endpoint types. Leverages endpoint health to support availability.

__Region-redundant solution__. Can route to many different endpoint types (Azure, external, nested)

__Communication FLow__ - User loads solution (DNS lookup), Traffic Manager provides IP address, User navigates to the appropriate solution

__Traffic Manage Profile__ - The profile is used to configure the endpoints which will be used, as well as the routing priority

Routing Methods

| Method      | Description                                                  |
| ----------- | ------------------------------------------------------------ |
| Priority    | Prioritised primary and backup endpoints                     |
| Weighted    | Distribution of traffic according to a weight value          |
| Performance | Send traffic to the "closest" endpoint                       |
| Geographic  | Route traffic based on the geographic location of the client |
| MultiValue  | Returns multiple endpoints to a request                      |
| Subnet      | Route based on the requester's IP address                    |

Azure portal -> Traffic Manager profile -> + Create -> create a unique DNS name -> Routing method: priority -> Select RG and region

Open the traffic manager profile -> Add endpoint -> Type: Azure endpoint -> Name it -> Target resource type: Public IP -> Choose the VM (You can only choose a pip with a DNS record associated)

## Azure Front Door

Web applications and delivery at a global scale. Whereas Azure Traffic Manager is dealing with DNS, Azure Front Door is like the Azure Application Gateway working across the globe. Layer 7. Leverages MS global edge network. Designed for web applications (HTTP/S). Supports Azure services, and on-remises (hybrid). Supports acceleration, caching, security, and more.

Say you deploy the Azure App Service across parts of the globe e.g. APAC and South America. Both are integrated with the same code repository (providing the same service, redundant). MS has edge networks all across the globe.. There are many __Point of Presence__. User will be pointed to their local Point of Presence. Azure Front door will ensure the lowest latency method is used. Once the slow connection is made to the local Point of Presence, a fast connection will be made from their to the nearest App Service.

Architecture Overview

__Frontend__ - Frontend Host/domain (can be custom) where traffic will be directed to for your global solution.

__Backend__ - Backend pool to service the solution, and supports integration with many Azure services, or custom/on-premises also.

__Routing__ - Connects the frontend and backend. Additional features can be configured, including caching and URL path matching.

[Front Door routing methods](https://docs.microsoft.com/en-us/azure/frontdoor/front-door-routing-methods)

## Web Application Firewalls in Azure

Protects web applications against threats and exploits. Protects against common threats and exploits, like SQL injection and cross-site scripting. Managed and custom rules for controlling access. Supported by Application Gateway and Front Door

WAF for Application Gateway and Front Door

| Application Gateway                                                   | Front Door                                                   |
| --------------------------------------------------------------------- | ------------------------------------------------------------ |
| Protects your solution at the VNet in your region                     | Protects your solution outside of your VNet, at the edge     |
| Supports Azure-managed and customer-managed rulesets                  | Supports Azure-managed and customer-managed rulesets         |
| Based on OWASP core rule set (CRS) 2.2.9, 3.0, and 3.1                | Protects against common top OWASP vulnerabilities by default |
| Supports custom geo-filtering rules, but rate-limiting is unavailable | Supports geo-filtering and rate-limiting rules               |

Azure Portal -> Open the Application gateway -> Web application firewall -> change Tier: WAF V2 -> Firewall status: Enabled -> Firewall mode: Detection or Prevention

Azure Portal -> Open the Azure Front Door -> Web application firewall -> No option to create one... see next steps

Azure Portal -> Web Application Firewall (WAF) -> Create -> Policy for: Global WAF (Front door) -> Name it and enable -> Mode: Detection or Prevention -> select any Exclusions -> Managed Rules: OWASP

## Azure AD Application Security

__Application Object__ within AAD represents various details about a real-world application. First it is registered in AAD. WHen an application object is created, a corresponding __service principal__ is created in the tenant. __Application Secrets__ are like credentials, it's so the application can prove it is the registered app.

AAD -> App registrations -> + New registration -> Name it -> Select this organisational directory only -> Certificates and secrets -> New secret -> name it -> Expires (1 yrs, 2 yrs, or Never) -> Take a copy of the secret to use later -> Open a resource e.g. SA -> Access Control (IAM) -> Add role assignment -> Role: Storage Queue Data Contributor (least privilege) -> Select the app just registered

Then in your code (GO, Python, C#, etc) you can use the Application (client) ID, Directory (tenant) ID, and the secret to access the SA Queue via the SP (app registration)

Example python code (Note space for client/tenant ids and secret):

```python
import uuid

# For working at the queue level, within a storage account
from azure.storage.queue import QueueClient

processing_queue_name = "QUEUENAME"
connect_str = "DefaultEndpointsProtocol=https;AccountName=STORAGEACCOUNTNAME;EndpointSuffix=core.windows.net"

# Authentication library
from azure.identity import ClientSecretCredential

# Information for authenticating using a Service Principal (the identity of our application)
tenant_id = " "
client_id = " "
client_secret =" "

# Get the application credentials
app_credentials = ClientSecretCredential(tenant_id, client_id, client_secret) 

# Create a queue client, using the application Azure AD credentials
queue_client = QueueClient.from_connection_string(connect_str, processing_queue_name, credential=app_credentials)
print("Client connected to Queue")

#### PROCESSING CLIENT ####

print("\nLet's PEEK at the messages in the queue...")

# Peek at messages in the queue
peeked_messages = queue_client.peek_messages(max_messages=5)

for peeked_message in peeked_messages:
    # List the message
    print("Message: " + peeked_message.content)
```

## Managed Identities

1. Azure identities for Azure Resources
2. Avoids the need for having to store credentials for your application/script within code. Azure manages the tenant/client ids and secret unlike SP (app registration)
3. Many services support managed identities, and these can authenticate to AAD

Key components:

* Azure resource must be assigned a system or user-managed identity
* The managed identity establishes a SP within Azure
* Instance metadata service (IMDS) is where your solution (code, script) can request a token from
* The Access Token can be used to authenticate with AAD

[Azure services that support managed identities for Azure resources](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/services-support-managed-identities#azure-services-that-support-managed-identities-for-azure-resources)

[Azure services that support Azure AD authentication](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/services-support-managed-identities#azure-services-that-support-azure-ad-authentication)

## Key Vault

A secure repository for secret information, with programmatic accessibility.

* Supports a variety of secret information, such as passwords, certificates, keys, and more
* FIPS 140-2 level hardware security modules (HSM)
* Certificates and key management support
* Centralised, secure accessibility using REST

Access policies - Control the access to secret information at the data layer.

When creating a new Key Vault you can select to enable _Soft delete_ and select the retention period in days. In the Access policy you can choose to add users, SPs or Managed identities. Here you can also enable access to Azure VMs for deployment, ARM for template deployments, and Azure Disk Encryption.

In the following example vm1 has a MI which is granted access to "kvtest" Key Vault in the access policy. From the Virtual machine:

Install AZ CLI:

``` powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile $home\Desktop\AzureCLI.msi

Start-Process msiexec.exe -Wait -ArgumentList "/I $home\Desktop\AzureCLI.msi /quiet"
```

Login using the managed identity:

```python
az login --identity --allow-no-subscriptions
```

Set a secret called mySecret with a password of secret123:

```python
az keyvault secret set --name mySecret --value secret123 --vault-name kvtest
```

Show the secret

```python
az keyvault secret show --name mySecret --vault-name kvtest
```

output:

```termial
{
  "attributes": {
    "created": "2021-02-05T17:24:54+00:00",
    "enabled": true,
    "expires": null,
    "notBefore": null,
    "recoveryLevel": "Recoverable+Purgeable",
    "updated": "2021-02-05T17:24:54+00:00"
  },
  "contentType": null,
  "id": "https://kvtest.vault.azure.net/secrets/mySecret/e8500f92ff0b46f0b496ea7315713ad2",
  "kid": null,
  "managed": null,
  "name": "mySecret",
  "tags": {
    "file-encoding": "utf-8"
  },
  "value": "secret123"
}
```

## Azure Update Management

Centralised update management, which provides OS patch management, scheduling and reporting. Supports Windows/Linux and Azure/on-premises.

Components:

* Automation Account - Service to facilitate the process automation and configuration management.
* Hybrid Runbook Worker - Customer-managed Windows or Linux OS which performs tasks.
* Log Analytics Workspace - Repo for log info, update management data.
* Log Analytics Agent - The software which routes logs/metrics data from Linux or Windows to the workspace.

Workflow:

1. Log Analytics agent on the OS - Report status (pre-update) - to Automation Account
2. You configure update schedules and review update assessments deployment statuses in the Automation Account
3. The Hybrid Runbook Worker checks for maintenance windows and deployment from the Automation Account.
4. Updates are installed on the OS.
   1. Pre-steps
   2. Updates
   3. Post-steps

Azure Portal -> Automation Account -> Update Management -> Add Azure VMs or Add non-Azure machine (Install Log Analytics agent)

## Azure Backups

Cloud-managed solution - Backup and recovery of data. Granular recovery levels, including files, folders, machine system state, and app-aware backups. Support for on-premises, Azure, and other clouds.

Components:

* Recovery Service Vault - A repo for backup data (for backups and DR) that controls many backup related settings
* Workload - supports range of workloads, such as Windows, Linux, and some backup-aware applications (SQL)
* Backup Agent - Server backup agents exist to support different workloads and scenarios (Such as on-premises, within Azure, etc)

Backup Agents:

__Microsoft Azure Recovery Services (MARS) Agent__ - Software installed on Windows to perform file-level backups to a registered recovery services vault.

* Provides file, folder, and system-state backups for Windows only
* Backs up 3x per day
* Restores files to a server

__Microsoft Azure Backup Server (MABS)__ - Backup suite which integrates with Azure backup to support traditional backups.

* Provides file, folder, volume, application, and system state backup
* Protects both Windows and Linux
* Customisable backup frequency

__Azure Virtual Machine Extension__ - Leverages a VM extension to backup a VM within Azure

* Supports VM-level backups of Windows and Linux
* Only Windows backups are application-consistent
* Backs up once per day
* Restores VMs, disks, and files

__Microsoft Data Protection Manager (DPM)__ - Traditional on-premises Microsoft backup solution

* Used for on-premises backups, but can also integrate with Azure Backup
* Supports tape

Azure Portal -> Recovery Services Vault -> + Add -> name, RG, Region -> Once created open Properties -> Backup Configuration: Locally-redundant or Geo-redundant

Azure Portal -> Recovery Services Vault -> Backup -> go through wizard for VM, on-premises, etc -> Create a new policy

[Azure Backup service](https://docs.microsoft.com/en-us/azure/backup/backup-overview#what-can-i-back-up)

## Azure Site Recovery

[Hyper-V to Azure disaster recovery architecture](https://docs.microsoft.com/en-us/azure/site-recovery/hyper-v-azure-architecture)
[VMware to Azure disaster recovery architecture](https://docs.microsoft.com/en-us/azure/site-recovery/vmware-azure-architecture)
[Physical server to Azure disaster recovery architecture](https://docs.microsoft.com/en-us/azure/site-recovery/physical-azure-architecture)

Helps businesses improve their ability to recover from major disasters:

* Recover from major failures at a region/site level
* Automated recovery processes
* Support for many different workloads (Azure, Hyper-V, VMware, and physical)
* Supports Windows and Linux

Components:

* Replicated Items - Workloads which are replicated between sites by Azure Site Recovery. These can be grouped (multi-VM consistency)
* Replication Policies - Defines recovery point objectives (RPO) and recovery point retention (0 - 72 hours) and supports app-consistent snapshots
* Recovery Plans - Help reduce RTO by providing functionality to automate failover.

Azure Portal -> Recovery Services Vaults -> Site Recovery -> Prepare Infrastructure

## Azure Migrate

Service which provides both MS and 3rd party migration tools. Server migrations (Hyper-V, VMware, physical), DB migrations (Database Migration Service), Application and data migrations, Assessment and migration tools.

Azure Portal -> Azure Migrate -> Servers -> Create a migration project

### Azure Migrate for Servers

[Support matrix for Hyper-V migration](https://docs.microsoft.com/en-us/azure/migrate/migrate-support-matrix-hyper-v-migration)
[Support matrix for VMware migration](https://docs.microsoft.com/en-us/azure/migrate/migrate-support-matrix-vmware-migration)
[Support matrix for physical server migration](https://docs.microsoft.com/en-us/azure/migrate/migrate-support-matrix-physical-migration)

Implementation

| Property        | Description                                                                                                          |
| --------------- | -------------------------------------------------------------------------------------------------------------------- |
| Migrate Project | Houses important metadata regarding assessment findings and migration activities                                     |
| Discovery       | Performed using the Azure Migrate appliance in your source environment, to identify servers to migrate               |
| Assessment      | Evaluate the identified server(s), provide estimated costs, and provide an assessment of the readiness for migration |
| Migration       | Migrate workloads, including VMware, Hyper-V, Physical, and public cloud VMs                                         |

Assessment

Azure Portal -> Azure Migrate -> Servers -> Azure Migrate: Server Assessment, Discover -> Discover using appliance (or Import using csv) -> Select whether VMware/Hyper-V/Physical -> Download and install appliance (.VHD for Hyper-V, .OVA for VMware - 12 GB) -> Load into on-premises Hyper-V host -> Boot appliance and register it with Azure (app on desktop), log into it, select subscription, Migrate Project, Name the appliance -> Enter credentials for the appliance to scan the Hyper-V host -> Start discovery

Migration

Azure Portal -> Azure Migrate -> Servers -> Azure Migrate: Server Migration -> Discover -> Are your machines virtualised: Yes with Hyper-V, select region and Create resources -> On the Hyper-V host, download the AzureSiteRecoveryProvider.exe software -> Run and register it -> select the downloaded .VaultCredentials file -> Finish

Azure Portal -> Azure Migrate -> Servers -> Azure Migrate: Server Migration -> Discover -> Are your machines virtualised: Yes with Hyper-V, Finalise registration -> Then replicate -> select Assessment and select the VMs -> select target RG, SA, VNet, and subnet -> compute options -> Disks -> Replicate

Watch the servers turn off in Hyper-V when migration begins. Check the RG when the migration is complete

### Azure Migrate for Databases

[Status of migration scenarios supported by Azure Database Migration Service](https://docs.microsoft.com/en-gb/azure/dms/resource-scenario-status)

| Property                   | Description                                                                                                                      |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Migrate Project            | Houses important metadata regarding assessment findings and migration activities                                                 |
| Assessment                 | Performed using the Azure Database Migration Assessment (DMA) tool. Evaluates a source DB, with a target destination (Azure SQL) |
| Database Migration Service | To facilitate the migration of data between source and target service, we use the Azure Database Migration Service (DMS)         |

Assessment

Azure Portal -> Azure Migrate -> Databases -> Download and install DMA on server with DB -> Select assessment, name the project, Assessment type: Database Engine, Source server type: SQL Server, Target server type: Azure SQL Database -> Create -> Run through the wizard and when complete: Upload to Azure Migrate

Migration

Azure Portal -> Azure Database Migration Service -> + create -> RG, Migration service name, region, Service mode: Azure, Pricing tier: Premium (More cores than standard tier which is free)
