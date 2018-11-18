
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
	-git commit -am "rebuild keepmywork system"
	git push $(TARGET_GIT)
    
local.Down:

remote.Up:
	mkdir -p $HOME/local/hooks/common
	cp hooks/* $HOME/local/hooks/common/
	chmod 700 $HOME/local/hooks/common/*

remote.Down:


up: $(TARGET).Up
down: $(TARGET).Down



