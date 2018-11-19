
ID_RSA_PEM=$(MAKE_DEFAULS)/id_rsa.pem

enc: $(CREDS_DIR)/creds.key1 $(CREDS_DIR)/creds.key2 $(CREDS_DIR)/creds.yaml.enc
$(CREDS_DIR)/creds.key1 $(CREDS_DIR)/creds.key2: $(CREDS_DIR)/creds.yaml.enc

$(CREDS_DIR)/creds.yaml.enc: $(CREDS_DIR)/creds.yaml $(MAKEFILE_DIR)/id_rsa.pub $(HOME)/.ssh/id_rsa.pub

	openssl rand -base64 32 > .key.bin
	ssh-keygen -f $(HOME)/.ssh/id_rsa.pub -e -m pem | openssl rsa -RSAPublicKey_in -pubout > .id_user.pem
	openssl rsautl -encrypt -inkey $(ID_RSA_PEM) -pubin -in .key.bin \
	  | openssl base64 -out $(CREDS_DIR)/creds.key1
	openssl rsautl -encrypt -inkey .id_user.pem -pubin -in .key.bin \
	  | openssl base64 -out $(CREDS_DIR)/creds.key2
	openssl enc -aes-256-cbc -a -salt -md sha1 -in $(CREDS_DIR)/creds.yaml -out $(CREDS_DIR)/creds.yaml.enc -pass file:.key.bin
	if [ -f $(CREDS_DIR)/openvpn.conf ]; then \
	  openssl enc -aes-256-cbc -a -salt -md sha1 -in $(CREDS_DIR)/openvpn.conf -out $(CREDS_DIR)/openvpn.conf.conf -pass file:.key.bin; \
	  git add $(CREDS_DIR)/openvpn.conf.enc; \
	  fi
	git rm --cached $(CREDS_DIR)/creds.yaml 2>/dev/null || true
	git add $(CREDS_DIR)/creds.yaml.enc $(CREDS_DIR)/creds.key1 $(CREDS_DIR)/creds.key2

	rm .key.bin .id_user.pem

local.Dec:
	openssl rsa -in $(HOME)/.ssh/id_rsa -outform pem > .id_user.pem
	openssl base64 -d -in $(CREDS_DIR)/creds.key2 \
	  | openssl rsautl -decrypt -inkey .id_user.pem -out .key.bin 
	  	
	openssl enc -a -d -md sha1 -aes-256-cbc -in $(CREDS_DIR)/creds.yaml.enc -out $(CREDS_DIR)/creds.yaml -pass file:.key.bin
	if [ -f $(CREDS_DIR)/openvpn.conf.enc ]; then \
	  openssl enc -a -d -md sha1 -aes-256-cbc -in $(CREDS_DIR)/openvpn.conf.enc -out $(CREDS_DIR)/openvpn.conf -pass file:.key.bin; \
	  fi
	
	rm .key.bin .id_user.pem

remote.Dec:
	openssl rsa -in $(MAKE_DEFAULTS)/id_rsa -inpass file:$(HOME)/.id_rsa.pass -outform pem > .id_rsa_.pem
	openssl base64 -d -in $(CREDS_DIR)/creds.key1 \
	  | openssl rsautl -decrypt -inkey .id_rsa_.pem -out .key.bin 
	  	
	openssl enc -a -d -md sha1 -aes-256-cbc -in $(CREDS_DIR)/creds.yaml.enc -out $(CREDS_DIR)/creds.yaml -pass file:.key.bin
	if [ -f $(CREDS_DIR)/openvpn.conf.enc ]; then \
	  openssl enc -a -d -md sha1 -aes-256-cbc -in $(CREDS_DIR)/openvpn.conf.enc -out $(CREDS_DIR)/openvpn.conf -pass file:.key.bin; \
	  fi
	
	rm .key.bin .id_rsa_.pem


dec: $(TARGET).Dec
