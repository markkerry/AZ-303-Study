# Implement and Manage Azure Infrastructure

## Azure AD

Identity Management - users, groups and other metadata

Enterprise Access Management - apps, sso, device management

Identity and Access Security - MFA, just-in-time access, identity protection, risk monitoring

### Implementing Azure AD

AAD can build a trust relationship between it and Azure Subscriptions and Office 365. Azure AD is the tenant and the single source of truth. First create with an initial _yourdomain_.onmicrosoft.com then add a custom domain using __TXT__ or __MX__ DNS records to verify that you own that domain. Note that it is important to create it in your local region for data sovereignty. Then you create an association/trust relationship with one or more Azure subscriptions.

To add a custom domain go to __AAD__ -> __Custom domain names__ -> __Add custom domain__ -> Enter the name. Add a TXT or MX record. Copy the __Destinaton or points to address__ info, open your DNS registrar create a new TXT record. The value is the __Distination or points to address__. Also copy in the TTL from Azure into DNS. After adding TXT to DNS go back to Azure and click Verify. Set the new custom domiain as the primary.

There is a difference between __swtich__ and __change__ directories. Switch will allow you to view that AAD tenant, authenticate to it, and manage the azure subscriptions within that directory/tenant. Change directory changes the subscription's association with that tenent/directory. Do not do without planning as affects RBAC among other things.

## Virtual Networks

Virtual Networks (VNet). Isolated within Azure

Subnet. VNets have one or more subnets.

Address Space. VNet has one or more address spaces. E.g. 10.1.0.0/16 for the VNet address space. Subnet1 with 10.1.1.0/24 and Subnet2 with 10.1.2.0/24 in the VNet. Microsoft will reserve .1, .2, and .4 ip address and well as .255. So the first IP in the subnet will be 10.1.1.4 and last will be 10.1.1.254

Smallest subnet allowed is /29 and largest is /8.

Custom DNS can be configured. DHCP is built in for the subnet, but custom DHCP cannot be deployed.

Can be integrated with ExpressRoute, Private Link and VPN.

System routes are default routes configured by Azure. By default any subnet in VNet has a route configured to the internet. There will also be connectivity between subnets. Go to the nic of the VM to see the __Effective Routes__. There you will see a prefix of 0.0.0.0/0 and next hop to the internet. That's effectively a wildcard which means if the address prefix is not defined in the effective routes, send the traffic to the internet.

Custom routes are user-defined routes which allow custom paths of communications to be enforced or blocked. Allows to block internet access from a particualr subnet, or force traffic to an Azure Firewall. Create a __Route Table__ resource in Azure to define custom routes. Block internet would be 0.0.0.0/0 and next hop set to __none__. Then associate that route with a subnet. If you wanted to specify that all googel DNS bound traffic goes through a virutal applicance you would do the following. Create a route, prefix of 8.8.8.8/32, next hop is virtual applicance, then IP of that appliance. The Nic of those machines need to then have IP forwarding enabled. Other things which will add to the route table is VNet Peering, Service Endpoints and ExpressRoute (BGP)

A Custom Route table will override any System (default) routes. Order of priority = Custom > BGP > System. Also the longer the prefix will override a shorter one. E.g. 10.0.0.0/32 will match more closely than 10.0.0.0/24.

## Virtual Machines
