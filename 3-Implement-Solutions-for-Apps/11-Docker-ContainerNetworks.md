# Docker Container Networks

```docker 
# create the frontend network
docker network create frontend

# Create the localhost network
docker network create localhost --internal

# Create a MySQL container that is attached to the localhost network
# -d for dettached, -e for environment variable
docker container run -d --name database --network localhost -e MYSQL_ROOT_PASSWORD=P4ssW0rd0! mysql:5.7

#Create an Nginx container that is attached to the localhost network
docker container run -d --name frontend-app --network frontend nginx:latest

# Connect frontend-app to the localhost network:
docker network connect localhost frontend-app

# check the frontend-app container is connected to both localhost and frontend networks
docker container inspect frontend-app

"Networks": {
    "frontend": {
        "IPAMConfig": null,
        "Links": null,
        "Aliases": [
            "b8ca3bbc3c91"
        ],
        "NetworkID": "a7329eb60bda6f6bed541a39f92e0f22e818d2d47286de7e404c7a2526980a48",
        "EndpointID": "677f9a4d59a34f3db49bbf92056b7c92b0a391a9b90059f236bb1959b4dd9f5d",
        "Gateway": "172.18.0.1",
        "IPAddress": "172.18.0.2",
        "IPPrefixLen": 16,
        "IPv6Gateway": "",
        "GlobalIPv6Address": "",
        "GlobalIPv6PrefixLen": 0,
        "MacAddress": "02:42:ac:12:00:02",
        "DriverOpts": null
    },
    "localhost": {
        "IPAMConfig": {},
        "Links": null,
        "Aliases": [
            "b8ca3bbc3c91"
        ],
        "NetworkID": "fcbbecec824ab8aa5f68458fa01c6917e7473ec573a3b90b606f7e3cca8ace49",
        "EndpointID": "becd98a2017219da66d63d517797bea17b422d3164bacee6abc89a0475c2dbe6",
        "Gateway": "172.19.0.1",
        "IPAddress": "172.19.0.3",
        "IPPrefixLen": 16,
        "IPv6Gateway": "",
        "GlobalIPv6Address": "",
        "GlobalIPv6PrefixLen": 0,
        "MacAddress": "02:42:ac:13:00:03",
        "DriverOpts": {}
    }
}

# And finally the database container should only be on the localhost network
docker container inspect database

"Networks": {
    "localhost": {
        "IPAMConfig": null,
        "Links": null,
        "Aliases": [
            "cd9baccdbcd0"
        ],
        "NetworkID": "fcbbecec824ab8aa5f68458fa01c6917e7473ec573a3b90b606f7e3cca8ace49",
        "EndpointID": "c0a1698a7230a3a44233ef36e1e30bce66c800209ac7d575d8025801c9b5ea5d",
        "Gateway": "172.19.0.1",
        "IPAddress": "172.19.0.2",
        "IPPrefixLen": 16,
        "IPv6Gateway": "",
        "GlobalIPv6Address": "",
        "GlobalIPv6PrefixLen": 0,
        "MacAddress": "02:42:ac:13:00:02",
        "DriverOpts": null
    }
}
```
