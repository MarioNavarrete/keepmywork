# Gitolite/Docker based deployment system


# Installation

## 1 Install Docker Server (DigitalOcean)

![](doc/img/do-docker.png)

```
> ssh root@do-server-ip
# docker network create --subnet=192.168.168.0/24 hub
# ufw disable
# ufw reset
# ufw limit ssh
# ufw allow http
# ufw allow https
# ufw limit mysql
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

Upload keepmywork scripts and setup hooks
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

## 4 Deploy Services and Apps

### Deploy NGINX Gate

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

Commit and Push changes to cretae new repository
```
> git commit -am "added repo nginx-gate" && git push
> cd ..
```

Deploy NGINX gateway
```
> git clone -o online git@do-server-ip:nginx-gate nginx-gate
> cd nginx-gate
> cp -r ../keepmywork/templates/nginx-gate/* .
> make certs
> make up
```

### Deploy MySQL Server

```
> cd gitolite-admin
```

Edit conf/gitolite.conf
```
epo gitolite-admin
    RW+     =   monster

repo keepmywork
    RW+     =   monster

repo nginx-gate
    RW+     =   monster

repo mysql-db
    RW+     =   monster
```

Commit and Push changes to cretae new repository
```
> git commit -am "added repo db-mysql" && git push
> cd ..
```

Deploy MySQL server
```
> git clone -o online git@do-server-ip:mysql-db mysql-db
> cd mysql-db
> cp -r ../keepmywork/templates/mysql-db/* .
> make certs
> make up
```

Connect to MySQL and change root password
```
> mysql -h do-server-ip -uroot -ptoor --ssl-ca=certs/mysqld-ca.pem --ssl-cert=certs/mysql-root-cert.pem --ssl-key=certs/mysql-root-key.pem

mysql > alter user 'root'@'%' identified by 'new-root-password';

mysql > \q
```

Create webapp user and database
```
> mysql -h do-server-ip -uroot -pnew-root-password --ssl-ca=certs/mysqld-ca.pem --ssl-cert=certs/mysql-root-cert.pem --ssl-key=certs/mysql-root-key.pem

mysql > create database webapp;

mysql > grant all on webapp.* to 'webapp'@'192.168.168.0/255.255.255.0' identifiied by 'password';
mysql > grant all on webapp.* to 'webapp'@'%' identified by 'password' require subject '/O=CLIENT/CN=user';

mysql > \q
```

Check webapp user connection
```
> mysql -h do-server-ip -uwebapp -ppassword --ssl-ca=certs/mysqld-ca.pem --ssl-cert=certs/mysql-user-cert.pem --ssl-key=certs/mysql-user-key.pem

mysql > \q
```

