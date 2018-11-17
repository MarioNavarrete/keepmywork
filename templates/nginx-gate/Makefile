
ifeq ($(origin KEEPMYWORK_GIT), undefined)
KEEPMYWORK_GIT = git@github.com:sudachen/keepmywork
endif

MAKEFILE_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
export MAKE_DEFAULTS = $(MAKEFILE_DIR)/.keepmywork/defaults

include .keepmywork/defaults/nginx.Makefile

.keepmywork/defaults/nginx.Makefile:
	git clone $(KEEPMYWORK_GIT) .keepmywork



