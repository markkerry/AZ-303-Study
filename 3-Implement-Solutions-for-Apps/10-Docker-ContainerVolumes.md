# Docker Container Volumes

``` bash
# create one
docker volume create tstvolume

docker volume ls
# DRIVER              VOLUME NAME
# local               tstvolume

docker volume inspect tstvolume
# [
#     {
#         "CreatedAt": "2021-03-03T17:14:55Z",
#         "Driver": "local",
#         "Labels": {},
#         "Mountpoint": "/var/lib/docker/volumes/tstvolume/_data",
#         "Name": "tstvolume",
#         "Options": {},
#         "Scope": "local"
#     }
# ]

# mount volume into a container. Create and app dir
docker container run -d --name devcontainer --mount source=tstvolume,target=/app nginx

# inpect it
docker container inspect devcontainer

sudo ls /var/lib/docker/volumes

# connect an interactive shell into the container
docker container exec -it devcontainer sh

# create a new file in app
echo "hello" >> app/hello.txt
# exit the container and delete it
docker container stop devcontainer
docker container rm devcontainer

# create a new one. use -v this time as volume already created/mounted
docker container run -d --name devcontainer2 -v tstvolume:/app nginx

# connect an interactive shell into the container
docker container exec -it devcontainer2 sh
cat app/hello.txt
# hello

# clean-up
docker container stop devcontainer2
docker container rm devcontainer2
docker volume remove tstvolume
```
