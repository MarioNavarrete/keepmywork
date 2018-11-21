# Gitolite/Docker based deployment system

:grey_exclamation: _**^D** means Ctrl+D_   
:grey_exclamation: _**do-server-ip** means IP address of your server_   
:grey_exclamation: _**your-github-name** means your github account name_   

# Installation

## 1 Create Docker Server (DigitalOcean)

![](docs/img/do-docker.png)

## 2 Setup Deployment System

Prepare system, install gitolite and setup git hooks 
```
$ ssh root@do-server-ip
# apt update && apt upgrade -y && reboot
$ ssh root@do-server-ip
# curl https://raw.githubusercontent.com/sudachen/keepmywork/master/setup_system | bash
# ^D
```

Clone gitolite config repo
```
$ git clone git@do-server-ip:gitolite-admin
$ cd gitolite-admin
```

Edit conf/gitolite.conf to add repo keepmywork
```
repo gitolite-admin
    RW+     =   monster

repo keepmywork
    RW+     =   monster
```

and commit repo
```
$ git commit -am "added repo keepmywork" && git push
$ cd ..
```

:exclamation: _Fork [sudachen/keepmywork](https://github.com/sudachen/keepmywork) on GitHub._

Upload keepmywork scripts and build deployment key
```
$ git clone git@github.com:your-github-name/keepmywork
$ cd keepmywork
$ git remote add online git@do-server-ip:keepmywork
$ make deployment-key
$ git push origin
```

## 3 Deploy Services and Apps

### NGINX Gate

```
$ cd gitolite-admin
```

Edit conf/gitolite.conf to add repo nginx-gate
```
repo gitolite-admin
    RW+     =   monster

repo keepmywork
    RW+     =   monster

repo nginx-gate
    RW+     =   monster
```

Commit and Push changes to create new deployment repository
```
$ git commit -am "added repo nginx-gate" && git push
$ cd ..
```

:exclamation: _Create repositiry named nginx-gate on github to store your specific modifications_

Deploy NGINX gateway
```
$ git clone origin git@github.com:your-github-name/nginx-gate
$ cd nginx-gate
$ git remote add online git@do-server-ip:nginx-gate
$ cp -r ../keepmywork/templates/nginx-gate/* .
$ make certs
$ git add . && git commit -am init && git push -u origin master
$ make up
```

### MySQL Server

```
$ cd gitolite-admin
```

Edit conf/gitolite.conf to add repo mysql-db
```
repo gitolite-admin
    RW+     =   monster

repo keepmywork
    RW+     =   monster

repo nginx-gate
    RW+     =   monster

repo mysql-db
    RW+     =   monster
```

Commit and Push changes to create new deployment repository
```
$ git commit -am "added repo mysql-db" && git push
$ cd ..
```

:exclamation: _Create repositiry named mysql-db on github to store your specific modifications_

Deploy MySQL server
```
$ git clone git@github.com:your-github-name/mysql-db
$ cd mysql-db
$ git remote add online git@do-server-ip:mysql-db
$ cp -r ../keepmywork/templates/mysql-db/* .
$ make certs
$ git add . && git commit -am init && git push -u origin master
$ make up
```

Connect to MySQL and change root password
```
$ make mysql-root-setup

mysql > alter user 'root'@'%' identified by 'new-root-password';

```

Create webapp user and database
```
mysql > create database webapp;
mysql > grant all on webapp.* to 'webapp'@'192.168.168.0/255.255.255.0' identifiied by 'password';
mysql > grant all on webapp.* to 'webapp'@'%' identified by 'password' require subject '/O=CLIENT/CN=user';

mysql > \q
```

Check webapp user connection
```
$ make mysql
user [monster]: webapp
Enter password:

mysql > \q
```
