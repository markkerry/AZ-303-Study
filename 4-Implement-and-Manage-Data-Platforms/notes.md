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
