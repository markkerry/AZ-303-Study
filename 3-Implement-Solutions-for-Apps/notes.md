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

## Containers in Azure

A Container has the app and dependencies packaged up, ready to be deployed to other machines.

Key Components

* __Dockerfile__ - Define exactly what we want our solution to look like. What OSm what files etc
* __Container Image__ - Using the Dockerfile we build a Container Image. This is stored in a repository, and is like a VM image. It's what we want to run. It can then be published to a Container Registry.
* __Container__ - The Container is an instance of a Container Image which is running on a Container Host. It might host a website, process data, etc

Azure Container Services

* __Container Development__ - largely no different than developing for containers which will be hosted elsewhere
* __Container Registry__ - You can manage your own registry with Azure Container Registry. Microsoft also hosts images in Microsoft Container Registry
* __Container Hosts__ - Several container hosting services, including Azure App Service, Azure Container Instances, and Azure Kubernetes Service

Example Dockerfile

Image based on nginx. Set the work directory and then copy the "src" folder to the work directory

```dockerfile
FROM nginx:alpine
WORKDIR /usr/share/nginx/html
COPY ./srv ./
```

build it

```bash
docker build --tag simplecontainer1 .
```

list the container

```bash
docker image ls
```

run the container, -d run the image but to detach it from current terminal, -p for port

```bash
docker run -d -p 8000:80 simplecontainer1
```

browse to localhost:8000 to view page in the container instance

## Azure Container Registry

* __Container Registry__ - Storage for private Docker container images. Based on Docker Registry 2.0, providing support for Docker and Azure services/tools (behind the scenes they are stored in Azure blobs)
* __Connectivity__ - Leverages two endpoints over HTTPS port 443:
  * REST API: for authentication and management
  * Storage: blob storage for container data
* __Docker Features__ - Such as namespaces and tagging. Also includes automation capabilities such as ACR Tasks

### Authentication

Azure Container Registry (ACR) supports:

* AAD based authentication, for AAD identities and service principles (users and apps)
* Admin user, for testing (disabled by default)

### Additional Security

ACR can be secured by:

* Firewall, Private Link, Service Endpoints
* Data encryption (enabled by default, can use customer managed keys)
* Using scoped permissions

### Pricing

* __Basic__ - Includes all standard capabilities, however has the least storage and throughput
* __Standard__ - Additional storage and throughput
* __Premium__ - Provides additional capabilities (e.g. geo-replication, firewalls) and increased performance/limits

### Create an ACR

Azure Portal -> Container Registry -> Create -> RG, name it (.azurecr.io), region, SKU: Premium -> Networking: Public Endpoint -> Encryption: Enabled, Select identity, from Key Vault, and select the Encryption Key -> Create

Go to Resource -> Networking to modify the who has access, selected networks, set the Firewall etc -> Go back to IAM to select RBAC access -> Back to Access keys, here you can select to enable the Admin user

```bash
# Get the name, login server and password from the Access Keys page of the ACR
docker login youracr.azurecr.io --username youracr

# tag the container
docker tag simplecontainer1 youracr.azurecr.io/sampleimages/simplecontainer1:latest

# Push the previously created container to the ACR. 
docker push youracr.azurecr.io/sampleimages/simplecontainer1:latest
```

Azure Portal -> ACR -> Repositories -> sampleimages/simplecontainer1 -> latest

## Azure Container Instances

Architecture:

* __Containers__ - Quick to deploy and fast to start, Azure Container Instances provides basic container functionality. Simple solutions; no orchestration
* __Networking__ - Deployed with public accessibility (public IP and FQDN). Or deployed to a VNet for private network access. solution.region.azurecontainer.io
* __Storage__ - Azure Azure Container Instances do not include full cluster functionality, persistent storage is still available using Azure files

Implementation:

* __Container Groups__ - Container Instances run within a Container Group. One container may contain the frontend, the other the backend. Compute, networking, and storage can be configured using YAML or ARM Templates
* __Restart Policy__
  * Always: restarts automatically on failure
  * On failure: restarts on nonzero exit codes
  * Never: containers will run at least once
* __Environment Variables__ - Can be used to store information as key/value pairs. This helps with dynamic configuration (e.g. connection strings)

Azure Portal -> Container Instances -> Create -> RG, Container Name, Images source: ACR or Docker Hub, Registry: youracr, Image: sampleimages/simplecontainer1, Image tag: latest, OS: Linux, CPU cores: 1, Memory: 0.5 GiB -> Networking: Public, Create a DNS label: appname.westeurope.azurecontainer.io, Ports/Protocol: 80/TCP -> Advanced: Restart policy: Always -> Create

Export the container as YAML to view

```bash
# from AZCLI
az container export -g rg-eu-containers --name container1 -f container.yml
code container.yaml
```

## Azure Web App for Containers

| __Web App__                                                      | __Web App for Containers__                                    |
| ---------------------------------------------------------------- | ------------------------------------------------------------- |
| Deploy a Web App using code, for a supported runtime environment | Deploy a Web App which is containerised, using your own image |
| Limited support for 3rd-party / custom dependencies              | Full control over the container image, including dependencies |
| Requires access to the source code of the solution               | Supports any solution that you can containerise               |

Architecture

* __Resource Group__ - You cannot mix Windows and Linux App Service Plans in the same Resource Group - Region
* __App Service Plan__ - The underlying infrastructure for your container. Defines all features. Note the OS must support the container image/framework
* __Web App Container__ - The container for your app, which can be sources from ACR, Docker Hub, or a private docker repo.

Azure Portal -> Web App -> Create -> Docker Container, Linux, region, app service plan SKU and Size -> Docker - Single container, image source: ACR, Select the Registry, Image, Tag created earlier.

## Azure Kubernetes Service

[Network concepts for applications in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/concepts-network)

Key Features:

* __Orchestration__ - Automatic scaling (horizontal pod scaling, cluster autoscaling), node upgrades, etc.
* __Docker Support__ - Support for Docker images, stored within ACR, or other public/private repositories
* __Persistent Storage__ - Provide static/dynamic storage volumes for solutions which require static content
* __AAD Integration__ - Configure an RBAC-enabled cluster for AAD user authentication support
* __VNet__ - Integrated VNet connectivity, and support for inbound access
* __Monitoring and Development__ - Advanced monitoring (Azure Monitor Insights) and debugging (Azure Dev Spaces)

Architecture:

* __Kubernetes Cluster__ - Comprised of the master (control pane) and the works (nodes). Within Kubernetes, a pod (app) runs on the worker nodes
* __Networking__ - Connectivity is established within a VNet using Kubernet networking, or Container Networking Interface (CNI)
* __Connectivity__ - Services are used to logically group pods for network connectivity (Cluster IP, NodePort, LoadBalancer, ExternalName)

Azure Portal -> Kubernetes Service -> Create -> RG, Cluster Name: aka01, Region, K8s version: 1.16.13 (default), primary node pool: size DS2v2, count 2 -> Node pools: Virtual Nodes Disabled, VMSS Enabled -> Authentication method: SP, RBAC: enabled, Encryption type: at-rest with a platform-managed key -> Networking: basic -> Container monitoring: enabled -> Create

## Azure Functions

* Code which is triggered to run by a range of events, without managing servers
* Supports C#, F#, PowerShell, JavaScript, and Python
* Integrates with a number of Azure services allowing both inbound and outbound data flows
* Enables cost savings (when using the consumption plan) - pay only for execution time

Architecture

* __Trigger__ - What causes the function to run. Timer, HTTP request, or new object in blob storage
* __Function App__ - Exists within a hosting plan. It contains important properties such as OS, runtime stack.
* __Bindings__ - Allow inbound and outbound access to resources, e.g. reading blob storage data and writing to table storage. Input and output bindings

Hosting plans

* __Consumption__ - Pay for execution of resources only (execution time, memory used). Scaling is managed automatically for you.
* __Premium__ - Provides additional features: warm instances, VNet connectivity, unlimited execution, and premium instance sizes.
* __App Service__ - Leverage dedicated VMs. Useful for custom images or existing underutilised plans.

Every Function App requires a SA to manage logging and triggers

## Logic Apps

Use either graphical design or code to build workflows which integrate with and control services in response to triggers. Workflow-as-a-service.

They are primarily made up of triggers and actions. Use Connectors to access data, services, systems. Use Workflow Definition Language (store in JSON).

* __Logic App__ - Deployed as either region-based or Integrated Service Environment (ISE). ISE provides dedicated resources within a VNet.
* __Workflow__ - Logic Apps are started by triggers (push or pull), which then include one or more actions (to perform a task . call a function, etc).
* __Connectors__ - Provides access to data, and to perform actions, with other MS or 3rd party services (both inside and outside of Azure).

Azure Portal -> Logic App -> Create -> RG, Name it, Region or ISE, Log Analytics Yes/No -> Create -> Go to Resource -> Logic App Designer

Logic Apps with HTTP triggers can have their URL secured with a SAS Access Key

Under Workflow settings, you can select an Integration account which can be used to manage the B2B artefacts.

## Azure App Service Monitoring

### Monitoring Metrics

* __Azure Monitor__ - App Service leverages Azure Monitor to provide access to metrics (as well as autoscale), for App Services apps
* __Metrics__ - Available by default and require no additional configuration for your App Service app. E.g. average response time
* __Quotas__ - Provides a view of the current utilisation of important resources, with respect to App Service Plan limitations

### Monitoring Logs

* __Integrated Logging__ - Azure App Service apps can expose log information both through the platform, as well as through Azure Monitor Logs
* __Diagnostic Logs__ - Gain access to app, web server, and other log info for your Windows and Linux apps. Can also be forwarded to Log Analytics
* __Activity Logs__ - For resource events. This includes info about the operations (who/when/what) for your apps.

Azure Portal -> App Service -> Monitoring / Metrics

Azure Portal -> App Service -> Monitoring / Logs (Log Analytics)

Azure Portal -> App Service -> Monitoring / App Service logs (On for Application logging to the App Service's File System or to a blob)

Azure Portal -> App Service -> Activity log

## Application Insights

An Application Performance Management (APM) service, which is targeted at providing developers with advanced monitoring capabilities. Application Insights supports a range of frameworks for solutions hosted in the cloud as well as on-premises.

Key Features

* __Supports Many Environments__ - Solutions built for .NET, Node.js, Java or Python are supported (Wherever the solution is hosted)
* __Usage Analytics__ - Includes a range of features to understand how users use your app e.g. retention
* __Metrics__ - Explore metrics over time (metrics explorer) or view them in near-real time (metrics streams)
* __Application Map__ - View connectivity between components to help understand health and performance
* __Application Profiler__ - Analyse and trace app performance, and gain an understanding of "hot" code
* __Alerts__ - For app performance and availability issues

Architecture

* __Application Insights__ - The resource acts as a repository for storing telemetry data for your solution (can be multiple components)
* __Instrumentation (code)__ - Use a server-side SDK within the app code, which leverages an instrumentation key to point to Application Insights
* __Instrumentation (codeless) - Some Azure services support Application Insights for your already-deployed app using an agent. Provides less functionality

Azure Portal -> RG, Name it, Region, Resource Mode: Classic -> Create -> Go to resource -> Notice the Instrumentation Key (This is what our app components will use to know where to send data to) and Connection String

You need to add the Application Insights SDK to your code and the configuration needs to point to our instrumentation key. Get that from:

App Service Plan -> Configuration -> Application Settings: Instrumentation Key

## Monitor for Containers

Features

* __Windows and Linux__ - Performance and health monitoring for Kubernetes clusters
* __Pod Monitoring__ - Gain Insights into the pod performance per node
* __Node Monitoring__ - Monitor node resource utilisation
* __Cluster Monitoring__ - Understand cluster behaviour whilst under load (average/peak)
* __Workload Monitoring__ - Monitor actual workload resource utilisation
* __Alerts__ - Configure alerts for resource utilisation on nodes/containers

Architecture

* __Container Monitoring__ - Monitor performance for K8s clusters (within Azure and elsewhere), as well as Azure Container Instances
* __Log Analytics__ - Info is stored after being retrieved from a containerised LA container agent
* __Monitoring Information__ - Gather performance data (metrics and diagnostics) from controllers, nodes, and containers

Deploy a containerised LA agent to the K8s environment:

Azure Portal -> Kubernetes Service - Monitoring / Insights (Onboard to Azure Monitor for Containers / Log Analytics)

Enable via Azure CLI

```bash
az aks enable-addons -a monitoring -n aksname -g rgName --workspace-resource-id "/subscriptions/GUID/resourceGroups/rgName/providers/Microsoft.OperationalInsights/workspace/workspaceName"
```
