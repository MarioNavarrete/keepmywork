# Gitolite/Docker based deployment system

:grey_exclamation: _**^D** means Ctrl+D_   
:grey_exclamation: _**do-server-ip** means IP address of your server_   
:grey_exclamation: _**HostedPojects** directory where you place your projects_

# Installation

## 1 Create Docker Server (DigitalOcean)

![](docs/img/do-docker.png)

## 2 Update your Linux System

Update an operating system
```
$ ssh root@do-server-ip
# apt update && apt upgrade -y && reboot
```
Wait a little now , server is rebooting. Then setup qeruired server compnents
```
$ ssh root@do-server-ip
# curl https://raw.githubusercontent.com/sudachen/keepmywork/master/setup_system | bash
# ^D
```

### 3 Deploy NGINX http(S) frontend

Create project and initailize its content
```
$ cd HostedProjects && mkdir frontend && cd frontend
$ git clone -o online git@do-server-ip:keepmywork .keepmywork
$ ./keepmywork/init nginx-gate .
```

Now you can change nginx configuration and then deply frontend by
```
$ make up
```

### 4 Deploy MySQL database server

Create project an initialize its content
```
$ cd HostedProjects && mkdir db && cd db
$ git clone -o online git@do-server-ip:keepmywork .keepmywork
$ ./keepmywork/init mysql-db .
```

Deploy MySQL server with default root password __toor__
```
$ make up
```

Connect to MySQL and change root password
```
$ ./mysql-root
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
$ ./mysql-user
user [monster]: webapp
Enter password:

mysql > \q
```
