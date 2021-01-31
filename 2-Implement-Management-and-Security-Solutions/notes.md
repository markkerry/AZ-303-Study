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
