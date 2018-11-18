
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
	git push $(TARGET_GIT) master
    
local.Down:

remote.Up:
	./setup_hooks

remote.Down:


up: $(TARGET).Up
down: $(TARGET).Down



