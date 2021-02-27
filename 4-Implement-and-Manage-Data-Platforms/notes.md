# Implement and Manage Data Platforms

## Cosmos DB

[Common Azure Cosmos DB use cases](https://docs.microsoft.com/en-gb/azure/cosmos-db/use-cases)

__SQL__ - Structured data, fixed format (schema) with tables, rows, columns and relationships. Emphasis on upfront planning. Difficult to modify. More commonly scaled vertically

__NoSQL__ - More flexible structure/format (various model, such as key/value, document, etc). Emphasis on long-term flexibility. Can be modified more easily. More commonly scaled horizontally.

Cosmos DB is Microsoft's NoSQL database platform which supports a range of data types and provides different APIs to interact with the data in many ways.

* __Multi-model__ - including key-value, documents, graphs, and columnar.
* __Massive scale__ - built for global scale and performance
* __Multi-master__ - supports active-active writes across replicas

* __SQL (Core) API__ - Access document data in the JSON format, using SQL-like queries
* __MongoDB API__ - Access document data in the BSON format, using MongoDB client SDK, drivers, and tools
* __Cassandra API__ - Access Columnar data using Cassandra Query Language (CQL)
* __Azure Table API__ - Access key-value data in the EDM format. This improves on Azure Table storage
* __Gremlin Graph API__ - Access graph-based data (vertex and edge) in JSON format, using Gremlin tools

## Cosmos DB Partitioning and Performance

[Partitioning and horizontal scaling in Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/partitioning-overview)

### Partitioning

* __Data__ - Within Cosmos DB, there are often several collections of data we wish to store (e.g. User Profile data stored in documents)
* __Logical Partition__ - Partitioning is when we pick a property (_partition key_ e.g. country) of the data, and use it to split the data in to logical groups
* __Physical Partition__ - The data ultimately needs to be stored on some infrastructure, which provides storage and compute capacity

Partitioning improves performance. It enables _horizontal_ scaling which can vastly improve performance

It is _Platform managed_ - Other than providing a partition key, the customer does not manage partitioning

### Performance Considerations

* __Request Units (RUs)__ - A RU is an abstracted way of measuring/charging for the resources (CPU, IOPS, memory) required to interact with data
* __Operations__ - Many operations can be performed in Cosmos DB (read, insert, upsert, delete, query). It costs 1 RU to fetch 1 x 1 KB item by item ID and partition key
* __Important Request Types__ - Point read: read by item ID and partition key. In-partition: query with partition key filter specified. Cross-partition: query without filter on partition key

## Implementing Cosmos DB

Resource Hierarchy

* Account - Fundamental unit of Cosmos DB. The __API__ is defined here. nameofaccount.documents.azure.com
* Database - The management layer for storing data. __Throughput__ can be defined here
* Containers - Where the data lives. __Partition key__ is defined here. __Throughput__ and __Unique ID__ can be also
* Item - The data itself. THis will be different things for different APIs e.g. document, row, etc

Azure Portal -> Cosmos DB -> Create -> Name it, API: Core (SQL), Region, Account Type: Production -> Connectivity: All networks -> Create -> Go to resource

Data Explorer -> New Container, New Database -> Database id: name it

Data Explorer -> New Container, New Container -> select the Database id, name the container id, partition key: /country

Select the container -> Items -> New Item -> Paste in the following

```json
{
    "userId": "1234",
    "name": "Mark",
    "country": "England"
}
```

After you save it the Cosmos DB will add a few more attributes, such as "id"

## Cosmos DB Replication

[How does Azure Cosmos DB provide high availability](https://docs.microsoft.com/en-us/azure/cosmos-db/high-availability)

Reasons to replicate:

* Highly Available - By creating (local and global) copies of our data, we can achieve HA
* Globally Distributed - When data is closer to users, performance can be improved for local users

Implementing:

* Replication - Cosmos DB transparently replicates data to all regions configured for a Cosmos DB account
* Multi-Region Writes - With replication enabled, secondary copies are available for read access. Multi-region writes allows write access to all replica copies

Azure Portal -> Azure Cosmos DB account -> Replicate data globally -> Add region

### Conflict Resolution

[Conflict types and resolution policies when using multiple write regions](https://docs.microsoft.com/en-us/azure/cosmos-db/conflict-resolution-policies)

* Last Write Wins
  * Uses system-defined timestamps to ensure last write wins
  * For insert or replace, the item with the highest value wins
  * For delete, the deleted version always wins over insert or replace
  * All regions are guaranteed to converge to a single winner
* Custom
  * Allows application-defined semantics for resolving conflicts
  * Register a stored merge procedure which is invoked in a conflict
  * If there is no stored procedure, or it fails, the conflict is logged and your application must manually resolve it

### Consistency

[Consistency levels in Azure Cosmos DB](https://docs.microsoft.com/en-us/azure/cosmos-db/consistency-levels)

Azure Portal -> Azure Cosmos DB account -> Default Consistency -> Strong / Bounded Staleness / Session / Consistent Prefix / Eventual

## Azure Tables

* NoSQL available in a storage account
* Key/Value pair
* Semi-structured - Store data that may change structure as entries (row data) in tabular format
* Storage optimised - Built and prices for storage focused solutions

Tables vs Cosmos DB

| Tables                                                      | Cosmos DB                                                 |
| ----------------------------------------------------------- | --------------------------------------------------------- |
| Built for storing tabular, semi-structured data (key-value) | Supports a variety of data model and APIs for NoSQL       |
| Pricing predominantly based on storage (cost per GB)        | Pricing predominantly based on throughput (request units) |
| Throughput limited to 20K operations/second                 | Throughput not limited (supports >10M operations/second)  |
| No latency guarantees                                       | < 10ms reads, < 15ms writes                               |
| Leverages storage account redundancy (read-only)            | Multi-master support for global access over many regions  |
| Indexed by single primary key (PartitionKey and RowKey)     | Automatically managed index (indexed on all properties)   |

## Azure SQL Database

Traditional MS SQL servers, fully managed, in the cloud. Includes patching, backups and more.

* Azure SQL Database - Suits new solutions that require SQL Server-like features
* Managed Instances - Suits solutions that require most SQL Server features
* Virtual Machines - Suits existing solutions which require 100% of SQL Server features

| DTU                                                          | vCore                                                     |
| ------------------------------------------------------------ | --------------------------------------------------------- |
| Database Transaction Unit (DTU) represents CPU, memory, IOPS | More granular control over CPU, memory, IOS               |
| Pricing per-DB                                               | Pricing per-DB                                            |
| Does not apply to Managed Instances or SQL VMs               | Supports Managed Instances, but does not apply to SQL VMs |
| Limited compute, memory, I/O, and storage limits             | Greater compute, memory, I/O, and storage limits          |
| Includes backups, patching, HA as part of the pricing        | Includes backups, patching, HA as part of the pricing     |

Service Tiers

* __General Purpose (vCore) and Standard (DTU)__ - Suitable for most generic workloads, this tier provides 99.99% SLA with a storage latency between 5 and 10 ms. Budget-orientated compute and storage
* __Business Critical (vCore) and Premium (DTU)__ - Designed for intensive workloads requiring low-latency storage (1-2 ms), and 99.995% multi-AZ SLA. Supports read cale-out through HA architecture
* __Hyperscale (vCore only)__ - Intended for business workloads that require up to 100 TB of storage. Supports read scale-out through HA architecture and fast scaling/restores

Further reading:

[General Purpose service tier - Azure SQL Database and Azure SQL Managed Instance](https://docs.microsoft.com/en-us/azure/azure-sql/database/service-tier-general-purpose)
[Business Critical tier - Azure SQL Database and Azure SQL Managed Instance](https://docs.microsoft.com/en-us/azure/azure-sql/database/service-tier-business-critical)
[Hyperscale service tier](https://docs.microsoft.com/en-us/azure/azure-sql/database/service-tier-hyperscale)
[Service tiers in the DTU-based purchase model](https://docs.microsoft.com/en-us/azure/azure-sql/database/service-tiers-dtu)
[SLA for Azure SQL Database](https://azure.microsoft.com/en-us/support/legal/sla/sql-database/v1_5/)

## Azure SQL Database Implementation

[Elastic pools help you manage and scale multiple databases in Azure SQL Database](https://docs.microsoft.com/en-us/azure/azure-sql/database/elastic-pool-overview)
[Authorize database access to SQL Database, SQL Managed Instance, and Azure Synapse Analytics](https://docs.microsoft.com/en-us/azure/azure-sql/database/logins-create-manage)

Key Components:

* __Logical Server__ - Central administration point for one or more databases/ Logins, firewall rules, failover, and more can be configured at this level. servername.database.windows.net
* __Database__ - The actual repo of structured info, stored in tables (rows and columns). Pricing is defined at this level
* __Access Control__ - 2 primary methods of access control:
  1. Firewall: filter network access (DB or server)
  2. Authentication/login: SQL and AAD

Azure Portal -> Azure SQL -> Create -> SQL databases/SQL managed instances/SQL VMs: SQL database (Single database) -> Name the DB, Create new Server -> Select size and pricing DTU or vCore -> Networking: No access -> Create

## Azure SQL Managed Instances

* A SQL Server cluster that's managed for you.
* SQL Server-like: near 100% of SQL server features
* Fully managed: Includes backups, patching etc
* Minimised change: Supports existing apps with minimal change

| SQL Database                                                      | Managed Instances                                                   |
| ----------------------------------------------------------------- | ------------------------------------------------------------------- |
| Built on top of the latest stable DQL Server code base            | Built on top of the latest stable DQL Server code base              |
| Includes built-in backups, patching, and HA (to 99.995%)          | Includes built-in backups, patching, and HA (to 99.995%)            |
| Supports many SQL language, query, and management features        | Supports almost 100% feature parity with SQL Server database engine |
| No native VNet connectivity                                       | Supports private IP address access within a VNet                    |
| Pricing: DTU and vCore                                            | Pricing: vCore                                                      |
| Service Tiers: General Purpose, Business Critical, and Hyperscale | Service Tiers: General Purpose and Business Critical                |

Key Components

* __Virtual Cluster__ - Managed compute and storage infrastructure for the SQL cluster. Hosted in subnet within a VNet. Accessible by managed DNS - miname.zone.database.windows.net
* __Databases__ - DBs housed within the cluster. These are customer managed using tools such as SSMS
* __Access Control__ - 2 primary methods of access control exist:
  1. Network: requires a NSG
  2. Authentication/login: SQL and AAD

Azure Portal -> Azure SQL -> Create -> SQL Managed Instances: Single instance -> MI name, pricing tier, admin creds -> Select VNet/Subnet, Proxy (default) -> Time zone -> Create

[Azure SQL Managed Instance connection types](https://docs.microsoft.com/en-us/azure/azure-sql/managed-instance/connection-types-overview)
[Azure SQL Managed Instance FAQ](https://docs.microsoft.com/en-us/azure/azure-sql/managed-instance/frequently-asked-questions-faq)

## Azure SQL High Availability

* Asynchronous Replication - Of primary DB with up to four secondaries
* Compatibility - Not supported by MI; only supported by Azure SQL Database
* Read Access - Secondary DBs can be leveraged for read-only access
* Manual Failover - Failover must be initiated manually by the application or a user

Active Geo-Replication Implementation

* __Logical Servers__ - Logical servers house the databases as usual. A secondary logical server is required wherever geo-replication will be configured.
* __Replication__ - Active geo-replication will allow up to four secondary copies to be created. These copies provide read-access also.
* __Failover and Access__ - Note that for failover and access:
  * Access: apps point to a server:database
  * Failover: must be managed by the app/user

Auto-Failover Groups

* __Asynchronous Replication__ - To another region
* __Compatibility__ - Replicate DBs for Managed Instances (all) and SQL DB (any)
* __Read Access__ - Secondary DBs can be leveraged for read-only access
* __Failover Management__ - Includes several features to improve the automation of failover

Auto-Failover Group Implementation

* __Failover Group__ - Configured in order to define the DBs to be replicated and the primary/secondary servers to be used
* __Listeners__ - Microsoft manages the DNS for:
  * Read-write: the current primary
  * Read: read-only access to the secondary
* __Failover Management__ - To support automated failover:
  * Policy: manual or automatic failover
  * Grace Period: time to wait before auto-failover
