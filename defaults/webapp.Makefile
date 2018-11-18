#

ifeq ($(strip $(SCRIPTS_STORE)),)
SCRIPTS_STORE=$(HOME)/store
endif

ifneq ($(strip $(DATABASE)),)
LINK_DB=--link $(DATABASE)
else
LINK_DB=
endif

ifneq ($(strip $(NETWORK)),)
LINK_NETWORK=--network $(NETWORK)
else
LINK_NETWORK=
endif

ifeq ($(strip $(APP)),)
APP=app
endif

ifeq ($(strip $(RQSDIR)),)
RQSDIR=app
endif

RUN_OPTIONS= $(LINK_DB) $(LINK_NETWORK)


CREDS_DIR=$(APP)

include $(MAKE_DEFAULTS)/updown.Makefile 
include $(MAKE_DEFAULTS)/creds.Makefile

remote.Up: build down
	@echo soft memory limit $${SOFTLIMIT:-32m}
	@docker run -d --name ${DEPLOY_NAME} \
	   --restart always \
	   -v/var/store/${DEPLOY_NAME}:/app/store:Z \
	   --network hub --network-alias ${DEPLOY_NAME}  \
	   --memory-reservation=$${SOFTLIMIT:-256m} \
	   --env UNICORNS=$${UNICORNS:-3} \
	   ${DEPLOY_NAME}	
	@echo docker is online
	
remote.Down:
	@ID=$$(docker ps -a -f name=${DEPLOY_NAME} | tail -n1 | cut -f1 -d ' ') && \
	  if [ "$${ID}" != "CONTAINER" ]; then docker stop ${DEPLOY_NAME} 2>/dev/null 1>&2; fi
	@ID=$$(docker container ls -a -f name=${DEPLOY_NAME} | tail -n1 | cut -f1 -d ' ') && \
	  if [ "$${ID}" != "CONTAINER" ]; then docker container rm ${DEPLOY_NAME} 2>/dev/null 1>&2; fi
	@echo docker is offline

build:
	if [ ! -f $(CREDS_DIR)/creds.yaml ] && [ ! -f $(CREDS_DIR)/creds.debug.yaml ]; then make dec; fi 
	-mkdir -p .build/rqs
	cp Dockerfile .build
	cp -r $(APP) .build/app
	cp $(RQSDIR)/requirements*.txt .build/rqs
	docker build -t ${DEPLOY_NAME}:test .build
	rm -r .build

webapp: build $(foreach x,$(TEST_SERVICES),$(x).Up)
	docker run --rm $(RUN_OPTIONS) --name ${DEPLOY_NAME}-test -it -p 8080:80 -p 5080:5000 ${DEPLOY_NAME}:test

ifneq ($(PYPY),)
ifeq ($(PYPY),YES)
PYPY=$(HOME)/pypy3
endif
VIRTUALENV=$(PYPY)/bin/virtualenv-pypy
VENV=.venv-pypy
else
VIRTUALENV=virtualenv
VENV=.venv
endif

$(VENV)/requiriments.ok: $(RQSDIR)/requirements.txt
	$(VIRTUALENV) --system-site-packages $(VENV)
	if [ -f $(VENV)/Scripts/activate ]; then ACTIVATE=$(VENV)/Scripts/activate; else ACTIVATE=$(VENV)/bin/activate; fi && \
		. $${ACTIVATE} && pip install -r $(RQSDIR)/requirements.txt
	touch $(VENV)/requiriments.ok

run: $(foreach x,$(TEST_SERVICES),$(x).Up) $(VENV)/requiriments.ok $(APP)/creds*.yaml
	if [ -f $(VENV)/Scripts/activate ]; then ACTIVATE=$(VENV)/Scripts/activate; else ACTIVATE=$(VENV)/bin/activate; fi && \
		. $${ACTIVATE} && cd $(APP) && python main.py

db.Upgrade: $(foreach x,$(TEST_SERVICES),$(x).Up) $(VENV)/requiriments.ok $(APP)/creds*.yaml
	if [ -f $(VENV)/Scripts/activate ]; then ACTIVATE=$(VENV)/Scripts/activate; else ACTIVATE=$(VENV)/bin/activate; fi && \
		. $${ACTIVATE} && cd $(APP) && python manage.py db upgrade

db.Migrate: $(foreach x,$(TEST_SERVICES),$(x).Up) $(VENV)/requiriments.ok $(APP)/creds*.yaml
	if [ -f $(VENV)/Scripts/activate ]; then ACTIVATE=$(VENV)/Scripts/activate; else ACTIVATE=$(VENV)/bin/activate; fi && \
		. $${ACTIVATE} && cd $(APP) && python manage.py db migrate

bash:
	docker exec -it ${DEPLOY_NAME}-test bash

