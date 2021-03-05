# Docker Commands

List docker images

``` bash
docker images
# or
docker image ls
```

Get running containers

``` bash
docker container ls
# if none are running and nothing is returned
docker container ls -a
# get the CONTAINER ID
```

Remove a container

``` bash
# 3892ee6a48ff is the CONTAINER ID
docker container rm 3892ee6a48ff
# or delete via the name
docker container rm my-python-container
# or finally remove two at the same time
docker container rm 3892ee6a48ff my-python-container
```

Remove an image

``` bash
# Get the IMAGE ID
docker images
# ca15defecd22 is the IMAGE ID
docker rmi ca15defecd22
```

Login to Docker Hub

``` bash
docker login
```

Tag a newly created container

```bash
docker tag ca15defecd22 markkerry/python3container:v1
# view the changes
docker images
```

Push the container to Docker Hub

```bash
docker push markkerry/python3container
```

Pull and image from public repo

```bash
docker pull markkerry/python3container:v1
```

Run a docker container interactively and remove upon exit

```bash
docker run -it --rm ansible-container
```

Run interactively, remove it upon exit and mount a volume called /ansible

```bash
docker run -it --rm --volume "$(pwd)":/ansible ansible-container
```

Specify the working directory

```bash
docker run -it --rm --volume "$(pwd)":/ansible -w /ansible ansible-container
```
