
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

include defaults/updown.Makefile

ifeq ($(origin DEPLOY_BRANCH), master)

$(HOME)/.id_rsa.pass:
	openssl rand -base64 15 > $(HOME)/.id_rsa.pass

$(MAKE_DEFAULTS)/id_rsa: $(HOME)/.id_rsa.pass
	@- if [ -f defaults/id_rsa -o -f defaults/id_rsa.pub ]; then rm -f defaults/id_rsa defaults/id_rsa.pub; fi
	@ssh-keygen -b 4096 -t rsa -f defaults/id_rsa -N $$(cat $(HOME)/.id_rsa.pass)
	@ssh-keygen -f defaults/id_rsa.pub -e -m pem | openssl rsa -RSAPublicKey_in -pubout > defaults/id_rsa.pem		
	@git config user.name = "keepmywork setup script"
	@git config user.email = "_@keepmywork.com"
	@git add defaults/id_rsa defaults/id_rsa.pub defaults/id_rsa.pem
	@git commit -am "added deployment rsa key"
	echo "added deployment RSA key, you have to pull repository back"

RSA: $(MAKE_DEFAULTS)/id_rsa		

else

RSA:

endif

remote.Up: RSA
	mkdir -p $(HOME)/local/hooks/common
	cp hooks/* $(HOME)/local/hooks/common/
	chmod 700 $(HOME)/local/hooks/common/*

remote.Down:

up: $(TARGET).Up
down: $(TARGET).Down

deployment-key:
	if [ -f defaults/id_rsa ]; then git rm -f defaults/id_rsa*; fi
	git commit -am "rebuild deployment key" || true
	git push $(TARGET_GIT)
	git pull $(TARGET_GIT) master
