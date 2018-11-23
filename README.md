# Gitolite/Docker based deployment system

:grey_exclamation: _**^D** means Ctrl+D_   
:grey_exclamation: _**do-server-ip** means IP address of your server_   
:grey_exclamation: _**your-github-name** means your github account name_   

# Installation

## 1 Create Docker Server (DigitalOcean)

![](docs/img/do-docker.png)

## 2 Update your Linux System
```
$ ssh root@do-server-ip
# apt update && apt upgrade -y && reboot
```

## 3 Inlitilize Deployment System
```
$ git clone -o github git@github.com:sudachen/keepmywork
$ cd keepmywork
$ git remote add online git@do-server-ip:keepmywork
$ ./init keepmywork
$ make up
$ cd ..
```

## 3 Deploy Main Services

### 4 Deploy NGINX gateway
```
$ ./keepmywork/init -up nginx-gate
```

### 5 Deply and Configure MySQL Server

```
$ ./keepmywork/init -up mysql-db 
```

Connect to MySQL and change root password, initial root password is __toor__
```
$ ./mysql-db/mysql-root
Enter password:

mysql > alter user 'root'@'%' identified by 'new-root-password';

```

Create webapp user and database if it's reqired
```
mysql > create database webapp;
mysql > grant all on webapp.* to 'webapp'@'192.168.168.0/255.255.255.0' identifiied by 'password';
mysql > grant all on webapp.* to 'webapp'@'%' identified by 'password' require subject '/O=CLIENT/CN=user';

mysql > \q
```

Check webapp user connection
```
$ ./mysql-db/mysql
user [monster]: webapp
Enter password:

mysql > \q
```
