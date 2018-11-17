SHELL=/bin/bash

ifeq ($(origin DEPLOY_NAME), undefined)
TARGET = local
export DEPLOY_NAME = nginx-gate
else
TARGET = remote
endif

ifeq ($(origin TARGET_GIT), undefined)
TARGET_GIT = online
endif

up: $TARGET.Up
down: $TARGET.Down

local.Up:
	if [ -f shutdown.txt ]; then echo no > shutdown.txt; fi
	date > TEST
	git commit -am "rebuild and up docker container"
	git push $(TARGET_GIT) HEAD:master
    
local.Down:
	echo yes > shutdown.txt
	git add shutdown.txt
	git commit -am "shutdown docker container"
	git push $(TARGET_GIT) HEAD:master

remote.Up: build remote.Down
	docker run -d --name ${DEPLOY_NAME} --restart always \
                --network hub \
                -p 80:80 \
                -p 443:443 \
                ${DEPLOY_NAME}

remote.Down:
	ID=$$(docker ps -a -f name=${DEPLOY_NAME} | tail -n1 | cut -f1 -d ' ') && \
          if [ "$${ID}" != "CONTAINER" ]; then docker stop ${DEPLOY_NAME} 2>/dev/null 1>&2; fi
	ID=$$(docker container ls -a -f name=${DEPLOY_NAME} | tail -n1 | cut -f1 -d ' ') && \
          if [ "$${ID}" != "CONTAINER" ]; then docker container rm ${DEPLOY_NAME} 2>/dev/null 1>&2; fi

build:  
	docker build -t ${DEPLOY_NAME} .
 	