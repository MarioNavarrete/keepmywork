SHELL=/bin/bash

include $(MAKE_DEFAULTS)/updown.Makefile 
include $(MAKE_DEFAULTS)/certs.Makefile 

remote.Up: build remote.Down
	@docker run --name ${DEPLOY_NAME} -d --restart always \
		--network hub \
		--network-alias ${DEPLOY_NAME} \
		--hostname $$(hostname) \
		-p 3306:3306 \
		-v /var/lib/mysql:/var/lib/mysql:Z \
		${DEPLOY_NAME} --character-set-server=utf8mb4
	@echo docker is online

remote.Down:
	@ID=$$(docker ps -a -f name=${DEPLOY_NAME} | tail -n1 | cut -f1 -d ' ') && \
	  if [ "$${ID}" != "CONTAINER" ]; then docker stop ${DEPLOY_NAME} 2>/dev/null 1>&2; fi
	@ID=$$(docker container ls -a -f name=${DEPLOY_NAME} | tail -n1 | cut -f1 -d ' ') && \
	  if [ "$${ID}" != "CONTAINER" ]; then docker container rm ${DEPLOY_NAME} 2>/dev/null 1>&2; fi
	@echo docker is offline


CERTS=certs/mysqld-cert.pem certs/mysqld-ca.pem
$(CERTS):
	cd certs && ./gencerts
certs: $(CERTS) enc
	git add $(CERTS)

remote.Build: remote.Dec
	docker 	build -t ${DEPLOY_NAME} .

local.Build:
	docker 	build -t ${DEPLOY_NAME} .
	
build: $(TARGET).Build	
