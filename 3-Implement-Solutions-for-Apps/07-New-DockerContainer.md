# Docker Commands

Create a new docker file

```bash
vim dockerfile
```

Add:

```docker
FROM ubuntu:16.04
RUN apt-get update
RUN apt-get install -y python3
```

Build it

```bash
docker build .
```

Get the IMAGE ID

```bash
docker image ls
```

Run it.

```bash
docker container run -it --name my-python-container ca15defecd22
```

Check you are running Ubuntu 16.04

```bash
cat /etc/issue
```

Check python3 is installed

```bash
python3
exit()
```

Install vim in the container

```bash
apt install vim -y
```

create a test script, add a print("Hello"). Make it executable and run it

```bash
vim hello.py
chmod +x hello.py
python3 hello.py
```

Exit the container. Causes it to stop

```bash
exit
```

Check if the container is stopped.

```bash
docker container ps
```

Start it again only this time non-interactive

```bash
docker container ls -a
docker container start my-python-container
```

Then to attach to it again

```bash
docker container ps
# or
docker container ls
docker attach ca15defecd22
```
