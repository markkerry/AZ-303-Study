# Implement and Manage Azure Infrastructure

## Azure AD

Identity Management - users, groups and other metadata
Enterprise Access Management - apps, sso, device management
Identity and Access Security - MFA, just-in-time access, identity protection, risk monitoring

### Implementing Azure AD

AAD can build a trust relationship between it and Azure Subscriptions and Office 365. Azure AD is the tenant and the single source of truth.
Create with an initial _yourdomain_.onmicrosoft.com then add a custom domain using __TXT__ or __MX__ DNS records to verify that you own that domain.
It's important to create it in your local region for data sovereignty.
Then you create an association/trust relationship with one or more Azure subscriptions.
