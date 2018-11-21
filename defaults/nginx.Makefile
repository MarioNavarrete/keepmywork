SHELL=/bin/bash

include $(MAKE_DEFAULTS)/updown.Makefile
include $(MAKE_DEFAULTS)/certs.Makefile 

remote.Up: remote.Build remote.Down
	docker run -d --name ${DEPLOY_NAME} --restart always \
                --network hub --hostname $$(hostname)\
                -p 80:80 \
                -p 443:443 \
                ${DEPLOY_NAME}

remote.Down:
	ID=$$(docker ps -a -f name=${DEPLOY_NAME} | tail -n1 | cut -f1 -d ' ') && \
          if [ "$${ID}" != "CONTAINER" ]; then docker stop ${DEPLOY_NAME} 2>/dev/null 1>&2; fi
	ID=$$(docker container ls -a -f name=${DEPLOY_NAME} | tail -n1 | cut -f1 -d ' ') && \
          if [ "$${ID}" != "CONTAINER" ]; then docker container rm ${DEPLOY_NAME} 2>/dev/null 1>&2; fi

remote.Build: remote.Dec local.Build

local.Build:  
	docker build -t ${DEPLOY_NAME} .
	
build: $(TARGET).Build	

CERTS = certs/nginx-cert.pem
$(CERTS):
	cd certs && ./gencerts
certs: $(CERTS) enc
	git add $(CERTS)
 	