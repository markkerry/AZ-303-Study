# Implement Solutions for Apps

## Azure App Service

* __Infrastructure Management__ - No need to patch, maintain, or manage underlying infrastructure
* __High Availability__ - Built-in support for HA. Azure App Service runs apps on multiple nodes
* __Auto-Scaling__ - Leverages familiar auto-scaling capabilities to ensure your app meets customer demands
* __Streamlined Development__ - Integrated development and troubleshooting tools to streamline development
* __CI/CD__ - For staging such as staging slots
* __Azure Integration__ - Integration with many Azure services and features, such as VNets and AAD

Pricing Tiers

* __Shared__ - Cheaper plans with fewer features, where your apps can run on the same compute as other customers
* __Dedicated__ - Only apps belonging to the App Service Plan run on these dedicated compute nodes
* __Isolated__ - Entirely dedicated, and isolated to a customer's network. Includes greater scale-out capacity

| Pricing Plan | Compute Type |
| ------------ | ------------ |
| Free         | Shared       |
| Shared       | Shared       |
| Basic        | Dedicated    |
| Standard     | Dedicated    |
| Premium      | Dedicated    |
| Isolated     | Isolated     |

Azure Portal -> App Service Plan -> Create -> Name it, RG, OS: Linux or Windows, Region, SKU and Size: Standard S1 -> Create

Once deployed can selected Scale Out and select a manual or auto-scale rule. Can also scale up but changing the plan to something with extra compute power. File system storage is capacity available to us by the storage plan.

## Azure Web Apps

To deploy a web application to Azure App Service, the hierarchy is as follows

* __RG__ - You cannot mix Windows and Linux App Service plans in the same RG - Region
* __App Service Plan__  - Defines both the available features, and the resources/capacity. This corresponds to "worker" VMs which will run your app
* __Web App__ - The container for your application. Defines many application level settings, such as runtime environment (.NET CORE), CI/CD, SSL, etc. Can have multiple apps, the other could be a PHP app

Azure Portal -> Web App -> Create -> RG of existing app service plan, Name the app (unique as name.azurewebsites.net), Publish: Code or Docker Container (code), Runtime stack: Node, PHP, Python, Java, ASP.NET, .NET Core -> Select App Service Plan -> Create

Open the Web App -> Custom Domains -> Add custom domain -> Validate it with TXT and CNAME records

## Azure App Service Deployments

Deployment basics:

* File Sync services - OneDrive, Dropbox
* FTP
* Azure Repos
* GitHub
* Bitbucket
* Local Git

Azure Portal -> Select your App Service -> Deployment Centre -> Manual Deployment (Push / Sync)

From AZ CLI - In the root of your source code

```bash
az webapp up -n NameOfWebApp -l "West Europe" -g RgName --dryrun
```

or build and zip your .net app

```bash
# build it
dotnet publish -o ./build

# zip it
cd build
zip -r AppName.zip *

# deploy it
az webapp deployment source config-zip --name AppName -g RgName --src AppName.zip
```

To get your app to talk to a SQL DB, open the App Service Web App -> Settings -> Configuration -> Add Connection String

## Deployment Slots

[Set up staging environments in Azure App Service](https://docs.microsoft.com/en-us/azure/app-service/deploy-staging-slots#which-settings-are-swapped)

Deployment Slots acts as standalone applications, with their own settings, which you can use for test and development.

The default slot is the "production slot" for your app. You can use additional slots for staging and testing. Slots can be promoted to production.

__Production Slot__ - Represents your active application, and where all users will connect to.
__Staging Slot__ - You can create additional slots (based on the App Service Plan) for staging. This is managed as a separate app/resource.
__Swap Operations__ - You can swap deployment slots to help with application upgrades, staging, and testing. Note: not all settings are swapped.

Azure Portal -> App Service -> Deployment SLots -> + Add Slot -> Name: Staging, Clone: Do not clone (if you want a different environment) -> Browse to the RG and you will see the new App Service (Slot) -> Has a new URL http://AppName-staging.azurewebsites.net. Connection strings and DNS will have to be setup again on the staging environment.

To deploy to staging, use the same command as above but with the slot parameter

```bash
az webapp deployment source config-zip --name AppName -g RgName --src AppName.zip --slot staging
```

When we push a staging slot into production, if we do not want the Connection string to be overwritten, we can open the connection string and tick "Deployment slot setting"

To test the new staging environment before swapping with production, click on Deployment Slots and set the Traffic on both slots to 50%. Or just click Swap. Changing will be highlighted, such as the connection string. If you ticked the above setting, the connection string in the staging slot will change to the connection string in the production slot.

## Azure App Service Networking and Security

* Inbound Connectivity - Apps are provided with ONE public inbound address (regardless of the number of instances). Configuring an IP-based TLS binding will make the IP address static.
* Outbound Connectivity - Can originate from many different public IP addresses. All addresses are used, so firewall rules must include ALL IP addresses.
* Access Restrictions - Allow/deny rules can be configured to control INBOUND networks access for your app. This is on a per-app basis. E.g. only allow your office public IP address inbound
* Encryption - To further secure traffic, SSL/TLS encryption can be configured. Private certs can encrypt inbound traffic. Public certs can be used by code (requires WEBSITE_LOAD_CERTIFICATES setting)

The virtual IP address of the web app can only be configured as static if you do so through an IP-based SSL binding. Take a note of the 4 Outbound IP addresses as they will have to be given inbound access to any SQL DBs you may want to use via a connection string.

Azure Portal -> Web App -> Properties -> note the Virtual IP and Outbound IP addresses

Azure Portal -> Web App -> Networking -> Access Restrictions -> + Add Rule -> The default allow all rule will change to deny all as soon as you create a custom allow rule

Azure Portal -> Web App -> TLS/SSL settings -> Private Key Certificates (.pfx) -> Upload Certificate -> Select the .pfx cert and password

Azure Portal -> Web App -> TLS/SSL settings -> Bindings -> Add TLS/SSL Binding -> select the custom domain and certificate just added, and the TLS/SSL type: IP based SSL or SNI SSL

### Network Integration

* VNet Integration - Allows outbound connectivity from the app to resources within the VNet. This does not provide a private IP address / inbound connection to the app itself (that would require Private Link)
* Hybrid Connections - Leveraging the Azure Relay / Hybrid Connections service, it is possible to access resources outside of Azure (on-premises). This technology only requires outbound connectivity over port 443 (TLS)

Azure Portal -> Web App -> Networking -> VNet Integration / Hybrid Connections

### Azure App Service Environment (ASE)

Where you deploy an App Service Environment to a Subnet in your VNet. This provides secure isolation, and VNet functionality such as connectivity and NSGs. Can access resources in the VNet or through to on-premises network via ExpressRoute or Site-to-Site VPN. There are two ways to deploy an ASE:

1. External ASE: uses an Internet accessible IP to provide public access.
2. Internal ASE: uses an Internal Load Balancer to provide private access.
