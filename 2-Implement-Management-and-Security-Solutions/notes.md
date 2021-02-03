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
