
CERTS_DIR=$(MAKEFILE_DIR)/certs
ID_RSA_PEM=$(MAKE_DEFAULTS)/id_rsa.pem

enc:  $(ID_RSA_PEM) $(HOME)/.ssh/id_rsa.pub
	openssl rand -base64 32 > .key.bin
	ssh-keygen -f $(HOME)/.ssh/id_rsa.pub -e -m pem | openssl rsa -RSAPublicKey_in -pubout > .id_user.pem
	openssl rsautl -encrypt -inkey $(ID_RSA_PEM) -pubin -in .key.bin \
	  | openssl base64 -out $(CERTS_DIR)/certs.key1
	openssl rsautl -encrypt -inkey .id_user.pem -pubin -in .key.bin \
	  | openssl base64 -out $(CERTS_DIR)/certs.key2	  

	for i in $(CERTS_DIR)/*-key.pem; do \
	  echo $$i $${i%.pem}; \
	  openssl enc -aes-256-cbc -a -salt -md sha1 -in $$i -out $$i.enc -pass file:.key.bin; \
	done

	git rm --cached $(CERTS_DIR)/*-key.pem 2>/dev/null || true
	git add $(CERTS_DIR)/*.enc $(CERTS_DIR)/certs.key[12]
	rm .key.bin .id_user.pem

local.Dec:
	openssl rsa -in $(HOME)/.ssh/id_rsa -outform pem > .id_user.pem
	openssl base64 -d -in $(CERTS_DIR)/certs.key2 \
	  | openssl rsautl -decrypt -inkey .id_user.pem -out .key.bin 
	for i in $(CERTS_DIR)/*.enc; do \
	   if [ ! -f $${i%.enc} ]; then \
	      openssl enc -d -aes-256-cbc -a -md sha1 -in $$i -out $${i%.enc} -pass file:.key.bin; \
	   fi; \
	done
	rm .key.bin .id_user.pem

remote.Dec:
	openssl rsa -in $(MAKE_DEFAULTS)/id_rsa -passin file:$(HOME)/.id_rsa.pass -outform pem > .id_rsa_.pem
	openssl base64 -d -in $(CERTS_DIR)/certs.key1 \
	  | openssl rsautl -decrypt -inkey .id_rsa_.pem -out .key.bin 
	for i in $(CERTS_DIR)/*.enc; do \
	  openssl enc -d -aes-256-cbc -a -md sha1 -in $$i -out $${i%.enc} -pass file:.key.bin; \
	done
	rm .key.bin .id_rsa_.pem


dec: $(TARGET).Dec

certs.Info:
	@for i in $$(ls certs/*.pem| grep -v -- '-key.'); do \
	  echo "$${i^^} -> "; \
	  openssl x509 -noout -fingerprint -issuer -subject -in $$i | while read; do echo " : "$$REPLY; done; \
	done
	