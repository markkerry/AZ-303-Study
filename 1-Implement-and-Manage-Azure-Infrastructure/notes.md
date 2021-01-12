# Implement and Manage Azure Infrastructure

## Azure AD

Identity Management - users, groups and other metadata
Enterprise Access Management - apps, sso, device management
Identity and Access Security - MFA, just-in-time access, identity protection, risk monitoring

### Implementing Azure AD

AAD can build a trust relationship between it and Azure Subscriptions and Office 365. Azure AD is the tenant and the single source of truth. First create with an initial _yourdomain_.onmicrosoft.com then add a custom domain using __TXT__ or __MX__ DNS records to verify that you own that domain. Note that it is important to create it in your local region for data sovereignty. Then you create an association/trust relationship with one or more Azure subscriptions.

To add a custom domain go to __AAD__ -> __Custom domain names__ -> __Add custom domain__ -> Enter the name. Add a TXT or MX record. Copy the __Destinaton or points to address__ info, open your DNS registrar create a new TXT record. The value is the __Distination or points to address__. Also copy in the TTL from Azure into DNS. After adding TXT to DNS go back to Azure and click Verify. Set the new custom domiain as the primary.

There is a difference between __swtich__ and __change__ directories. Switch will allow you to view that AAD tenant, authenticate to it, and manage the azure subscriptions within that directory/tenant. Change directory changes the subscription's association with that tenent/directory. Do not do without planning as affects RBAC among other things.
