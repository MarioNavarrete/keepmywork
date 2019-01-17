export REVISION := 1.1
export BASE_REVISION := $(REVISION)
export OWNER := sudachen

ALL = pyscript webapp
all: update

pyscript.Update:
	IMAGE=$(basename $@) $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker update
webapp.Update: 
	IMAGE=$(basename $@) BASE_IMAGE= BASE_REVISION=latest $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker update
hugapp.Update: 
	IMAGE=$(basename $@) BASE_IMAGE= BASE_REVISION=latest $(MAKE) -C $(basename $@) -f $(PWD)/Makefile.docker update

%.Push:
	docker push ${OWNER}/$(basename $@):${REVISION}
	docker tag ${OWNER}/$(basename $@):${REVISION} ${OWNER}/$(basename $@):latest
	docker push ${OWNER}/$(basename $@):latest

%.Pull:
	docker pull ${OWNER}/$(basename $@):${REVISION}
	docker pull ${OWNER}/$(basename $@):latest

push:   $(foreach img, $(ALL), $(img).Push) 
pull:   $(foreach img, $(ALL), $(img).Pull)
update: $(foreach img, $(ALL), $(img).Update)
