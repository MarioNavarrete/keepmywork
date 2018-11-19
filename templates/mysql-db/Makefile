
ifeq ($(origin KEEPMYWORK_GIT), undefined)
  GIT_REMOTE = $(shell git remote)
    ifeq ($(findstring online, $(GIT_REMOTE)),)
      KEEPMYWORK_GIT = git@github.com:sudachen/keepmywork
    else
      GIT_URL = $(shell git remote get-url online)
      KEEPMYWORK_GIT = $(firstword $(subst :, ,$(GIT_URL))):keepmywork
    endif
endif

MAKEFILE_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

ifeq ($(origin DEPLOY_NAME), undefined)

export MAKE_DEFAULTS = $(MAKEFILE_DIR)/.keepmywork/defaults
include .keepmywork/defaults/mysql.Makefile
.keepmywork/defaults/mysql.Makefile:
	git clone $(KEEPMYWORK_GIT) .keepmywork

else

include $(MAKE_DEFAULTS)/mysql.Makefile

endif




