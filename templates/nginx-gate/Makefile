
MAKEFILE_PFX=nginx

GIT_URL = $(shell git remote get-url online)
GIT_HOST = $(lastword $(subst @, ,$(firstword $(subst :, ,$(GIT_URL))))
KEEPMYWORK_GIT = $(firstword $(subst :, ,$(GIT_URL))):keepmywork
MAKEFILE_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

ifeq ($(origin DEPLOY_NAME), undefined)

export MAKE_DEFAULTS = $(MAKEFILE_DIR)/.keepmywork/defaults
include .keepmywork/defaults/$(MAKEFILE_PFX).Makefile
.keepmywork/defaults/$(MAKEFILE_PFX).Makefile:
	git clone $(KEEPMYWORK_GIT) .keepmywork

else

include $(MAKE_DEFAULTS)/$(MAKEFILE_PFX).Makefile

endif




