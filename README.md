# Gitolite/Docker based deployment system


# Installation

## 1 Install Docker Server (DigitalOcean)

![](doc/img/do-docker.png)

```
> ssh root@do-server-ip
# docker network create --subnet=192.168.168.0/24 hub
# ufw disable
# ufw reset
# ufw allow ssh
# ufw allow http
# ufw allow https
# ufw enable
# exit
```

## 2 Install GitoLite

```
> ssh root@do-server-ip
# locale-gen en_US.UTF-8
# update-locale LANG=en_US.UTF-8
# cat >> /etc/environment 
LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8 
LANGUAGE=en_US.UTF-8 
^D
# useradd -r -m -s /bin/bash git
# usermod -a -G docker git
# exit
> scp ~/.ssh/id_rsa.pub root@do-server-ip:/home/git/monster.pub
> ssh root@do-server-ip
# sudo -i -u git
$ git clone https://github.com/sitaramc/gitolite
$ mkdir bin
$ gitolite/install -to $HOME/bin
$ bin/gitolite setup -pk monster.pub
$ exit
# exit
```

## 3 Setup Deployment System

```
> git clone git@do-server-ip:gitolite-admin
> cd gitolite-admin
```

Edit conf/gitolite.conf
```
repo gitolite-admin
    RW+     =   monster

repo keepmywork
    RW+     =   monster
```

and commit repo

```
> git commit -am "added repo keepmywork" && git push
> cd ..
```

Now setup keepmywork scripts

```
> git clone git@github.com:sudachen/keepmywork
> cd keepmywork
> git remote add online git@do-server-ip:keepmywork
> git checkout -b online
> git push -u online online:master
> ssh root@do-server-ip
# sudo -i -u git
$ git clone file://$HOME/repositories/keepmywork.git keepmywork
$ cd keepmywork
$ ./setup_hooks
$ cd ..
```

## Setup NGINX Gate

```
> cd gitolite-admin
```

Edit conf/gitolite.conf
```
repo gitolite-admin
    RW+     =   monster

repo keepmywork
    RW+     =   monster

repo nginx-gate
    RW+     =   monster
```

```
> git commit -am "added repo nginx-gate" && git push
> cd ..
```

> git clone -o online git@do-server-ip:nginx-gate nginx-gate
> cd nginx-gate
> cp -r ../keepmywork/templates/nginx-gate/* .
> make up

