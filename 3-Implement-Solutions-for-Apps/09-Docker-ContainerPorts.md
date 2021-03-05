# Docker Container Ports

``` bash
# -d means it runs attached
docker container run -d nginx

docker container ls # notice PORTS = 80/tcp
# CONTAINER ID    IMAGE    COMMAND                  CREATED          STATUS           PORTS     NAMES
# ca697bf5fcd9    nginx    "/docker-entrypoint.…"   15 seconds ago   Up 14 seconds    80/tcp    epic_merkle

# this command shows you what port will be exposed. 
docker image history nginx
# IMAGE               CREATED             CREATED BY                                      SIZE
# 35c43ace9216        13 days ago         /bin/sh -c #(nop)  CMD ["nginx" "-g" "daemon…   0B
# <missing>           13 days ago         /bin/sh -c #(nop)  STOPSIGNAL SIGQUIT           0B
# <missing>           13 days ago         /bin/sh -c #(nop)  EXPOSE 80                    0B
# <missing>           13 days ago         /bin/sh -c #(nop)  ENTRYPOINT ["/docker-entr…   0B
# <missing>           13 days ago         /bin/sh -c #(nop) COPY file:c7f3907578be6851…   4.62kB
# <missing>           13 days ago         /bin/sh -c #(nop) COPY file:0fd5fca330dcd6a7…   1.04kB
# <missing>           13 days ago         /bin/sh -c #(nop) COPY file:0b866ff3fc1ef5b0…   1.96kB
# <missing>           13 days ago         /bin/sh -c #(nop) COPY file:65504f71f5855ca0…   1.2kB
# <missing>           13 days ago         /bin/sh -c set -x     && addgroup --system -…   63.8MB
# <missing>           13 days ago         /bin/sh -c #(nop)  ENV PKG_RELEASE=1~buster     0B
# <missing>           13 days ago         /bin/sh -c #(nop)  ENV NJS_VERSION=0.5.1        0B
# <missing>           13 days ago         /bin/sh -c #(nop)  ENV NGINX_VERSION=1.19.7     0B
# <missing>           3 weeks ago         /bin/sh -c #(nop)  LABEL maintainer=NGINX Do…   0B
# <missing>           3 weeks ago         /bin/sh -c #(nop)  CMD ["bash"]                 0B
# <missing>           3 weeks ago         /bin/sh -c #(nop) ADD file:d5c41bfaf15180481…   69.2MB

# get the IP ADDR
docker container inspect ca697bf5fcd9 | grep IPAdd

# "SecondaryIPAddresses": null,
# "IPAddress": "172.17.0.2",
#     "IPAddress": "172.17.0.2",

# Install elinks if not already installed
# CentOS 8
sudo yum --enablerepo=PowerTools install -y elinks
# Ubunutu
sudo apt install -y elinks

# connect with elinks
elinks 172.17.0.2

# Set localhost to listen on port 80 with -P for a random port. lower-case -p to specify a port 80:80
docker container run -d -P nginx
docker container ls
# CONTAINER ID   IMAGE   COMMAND                  CREATED           STATUS           PORTS                   NAMES
# 28d89232df8a   nginx   "/docker-entrypoint.…"   19 seconds ago    Up 18 seconds    0.0.0.0:49153->80/tcp   distracted_wright
```
