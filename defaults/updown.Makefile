
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

up: $(TARGET).Up
down: $(TARGET).Down

local.Up:
	-git commit -am "rebuild and up docker container"
	BRANCH=$$(git branch|grep '*'|sed -e 's/[* ]//g') && \
	if git checkout -b _online_ ; then \
	   date > TEST &&\
	   git add TEST &&\
	   git commit -am "deploying" &&\
	   rm TEST &&\
	   git push $(TARGET_GIT) HEAD:online -f ;\
	   git checkout $$BRANCH;\
	   git branch -D _online_; \
	fi
    
local.Down:
	echo yes > shutdown.txt
	git add shutdown.txt
	git commit -am "shutdown docker container"
	git push $(TARGET_GIT) HEAD:master

