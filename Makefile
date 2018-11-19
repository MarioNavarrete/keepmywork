
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

$(HOME)/.id_rsa.pass:
	openssl rand -base64 15 > $(HOME)/.id_rsa.pass

$(MAKE_DEFAULTS)/id_rsa: $(HOME)/.id_rsa.pass
	@- if [ -f defaults/id_rsa -o -f defaults/id_rsa.pub ]; then rm -f defaults/id_rsa defaults/id_rsa.pub; fi
	@ssh-keygen -b 4096 -t rsa -f defaults/id_rsa -N $$(cat $(HOME)/.id_rsa.pass)
	@ssh-keygen -f defaults/id_rsa.pub -e -m pem | openssl rsa -RSAPublicKey_in -pubout > defaults/id_rsa.pem	
	@git config user.name = "keepmywork setup script"
	@git config user.email = "_@keepmywork.com"
	@git add defaults/id_rsa defaults/id_rsa.pub defaults/id_rsa.pem
	@git commit -am "added deployment rsa key" && git push
	echo "added deployment RSA key, you have to pull repository back"
		
remote.Up: $(MAKE_DEFAULTS)/id_rsa
	mkdir -p $(HOME)/local/hooks/common
	cp hooks/* $(HOME)/local/hooks/common/
	chmod 700 $(HOME)/local/hooks/common/*


remote.Down:


up: $(TARGET).Up
down: $(TARGET).Down



